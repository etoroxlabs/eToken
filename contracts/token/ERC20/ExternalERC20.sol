/* solium-disable max-len */

pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./ExternalERC20Storage.sol";

/**
 * @title External ERC20 token
 *
 * @dev Implementation of the standard token
 * but with an external storage implemented as ExternalERC20Storage.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ExternalERC20 is IERC20 {
    using SafeMath for uint256;

    ExternalERC20Storage public _externalERC20Storage;

    /**
     * @dev Constructor
     * @param externalERC20Storage The external storage contract.
     * This is the only time you can change it
     */
    constructor(
        ExternalERC20Storage externalERC20Storage,
        bool shouldCreateStorage
    )
        public
    {

        require(
            (externalERC20Storage != address(0) && (!shouldCreateStorage)) ||
            (externalERC20Storage == address(0) && shouldCreateStorage),
            "Cannot both create external storage and use existing one.");

        if (shouldCreateStorage) {
            _externalERC20Storage = new ExternalERC20Storage(msg.sender, this);
        } else {
            _externalERC20Storage = externalERC20Storage;
        }
    }

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _externalERC20Storage.totalSupply();
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _externalERC20Storage.balances(owner);
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _externalERC20Storage.allowed(owner, spender);
    }

    /**
     * @dev Transfer token for a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool)
    {
        _transferFrom(
            msg.sender,
            from, to,
            value
        );
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _increaseAllowance(msg.sender, spender, addedValue);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _decreaseAllowance(msg.sender, spender, subtractedValue);
        return true;
    }

    /**
     * @dev Internal function implementing the functionality of approve
     */
    function _approve(address originSender, address spender, uint256 value) internal {
        require(spender != address(0));

        _externalERC20Storage.setAllowed(originSender, spender, value);
        emit Approval(originSender, spender, value);
    }

    /**
     * @dev Internal function implementing the functionality of transferFrom
     */
    function _transferFrom(
        address originSender,
        address from,
        address to,
        uint256 value
    )
        internal
    {
        require(value <= _externalERC20Storage.allowed(from, originSender));

        _externalERC20Storage.setAllowed(
            from, originSender,
            _externalERC20Storage.allowed(from, originSender).sub(value)
        );
        _transfer(from, to, value);
    }

    /**
     * @dev Internal function implementing the functionality of increaseAllowance
     */
    function _increaseAllowance(address originSender, address spender, uint256 addedValue)
        internal
    {
        require(spender != address(0));

        _externalERC20Storage.setAllowed(
            originSender, spender,
            _externalERC20Storage.allowed(originSender, spender).add(addedValue)
        );
        emit Approval(
            originSender, spender,
            _externalERC20Storage.allowed(originSender, spender)
        );
    }

    /**
     * @dev Internal function implementing the functionality of decreaseAllowance
     */
    function _decreaseAllowance(address originSender, address spender, uint256 subtractedValue)
        internal
    {
        require(spender != address(0));

        _externalERC20Storage.setAllowed(
            originSender, spender,
            _externalERC20Storage.allowed(originSender, spender).sub(subtractedValue)
        );
        emit Approval(
            originSender, spender,
            _externalERC20Storage.allowed(originSender, spender)
        );
    }


    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(value <= _externalERC20Storage.balances(from));
        require(to != address(0));

        _externalERC20Storage.setBalance(from, _externalERC20Storage.balances(from).sub(value));
        _externalERC20Storage.setBalance(to, _externalERC20Storage.balances(to).add(value));

        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != 0);
        _externalERC20Storage.setTotalSupply(_externalERC20Storage.totalSupply().add(value));
        _externalERC20Storage.setBalance(account, _externalERC20Storage.balances(account).add(value));
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != 0);
        require(value <= _externalERC20Storage.balances(account));

        _externalERC20Storage.setTotalSupply(_externalERC20Storage.totalSupply().sub(value));
        _externalERC20Storage.setBalance(account, _externalERC20Storage.balances(account).sub(value));
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address burner, address account, uint256 value) internal {
        require(value <= _externalERC20Storage.allowed(account, burner));

        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        _externalERC20Storage
            .setAllowed(
                account, burner,
                _externalERC20Storage.allowed(account, burner).sub(value)
            );
        _burn(account, value);
    }
}
