pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./Storage.sol";

contract ERC20 {
    using SafeMath for uint256;

    Storage public _storage;

    string private _name_;
    string private _symbol_;
    uint8 private _decimals_;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Constructor
     * @param name The ERC20 detailed token name
     * @param symbol The ERC20 detailed symbol name
     * @param decimals Determines the number of decimals of this token
     * @param externalStorage The external storage contract.
     * Should be zero address if shouldCreateStorage is true.
     * @param initialDeployment Defines whether it should
     * create a new external storage. Should be false if
     * externalERC20Storage is defined.
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Storage externalStorage,
        bool initialDeployment
    )
        public
    {

        require(
            (externalStorage != address(0) && (!initialDeployment)) ||
            (externalStorage == address(0) && initialDeployment),
            "Cannot both create external storage and use the provided one.");

        _name_ = name;
        _symbol_ = symbol;
        _decimals_ = decimals;

        if (initialDeployment) {
            _storage = new Storage(msg.sender, this);
        } else {
            _storage = externalStorage;
        }
    }

    /**
     * @return the name of the token.
     */
    function _name() internal view returns(string) {
        return _name_;
    }

    /**
     * @return the symbol of the token.
     */
    function _symbol() internal view returns(string) {
        return _symbol_;
    }

    /**
     * @return the number of decimals of the token.
     */
    function _decimals() internal view returns(uint8) {
        return _decimals_;
    }

    /**
     * @dev Total number of tokens in existence
     */
    function _totalSupply() internal view returns (uint256) {
        return _storage.totalSupply();
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function _balanceOf(address owner) internal view returns (uint256) {
        return _storage.balances(owner);
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function _allowance(address owner, address spender)
        internal
        view
        returns (uint256)
    {
        return _storage.allowed(owner, spender);
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param originSender The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address originSender, address to, uint256 value)
        internal
        returns (bool)
    {
        require(value <= _storage.balances(originSender));
        require(to != address(0));

        _storage.setBalance(originSender, _storage.balances(originSender).sub(value));
        _storage.setBalance(to, _storage.balances(to).add(value));

        emit Transfer(originSender, to, value);

        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param originSender the original transaction sender
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function _approve(address originSender, address spender, uint256 value)
        internal
        returns (bool)
    {
        require(spender != address(0));

        _storage.setAllowed(originSender, spender, value);
        emit Approval(originSender, spender, value);

        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param originSender the original transaction sender
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function _transferFrom(
        address originSender,
        address from,
        address to,
        uint256 value
    )
        internal
        returns (bool)
    {
        require(value <= _storage.allowed(from, originSender));

        _storage.setAllowed(
            from, originSender,
            _storage.allowed(from, originSender).sub(value)
        );
        _transfer(from, to, value);
        emit Approval(from, originSender, _storage.allowed(from, originSender));

        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param originSender the original transaction sender
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function _increaseAllowance(address originSender, address spender, uint256 addedValue)
        internal
        returns (bool)
    {
        require(spender != address(0));

        _storage.setAllowed(
            originSender, spender,
            _storage.allowed(originSender, spender).add(addedValue)
        );
        emit Approval(
            originSender, spender,
            _storage.allowed(originSender, spender)
        );

        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param originSender the original transaction sender
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function _decreaseAllowance(
        address originSender,
        address spender,
        uint256 subtractedValue
    )
        internal
        returns (bool)
    {
        require(spender != address(0));

        _storage.setAllowed(
            originSender, spender,
            _storage.allowed(originSender, spender).sub(subtractedValue)
        );
        emit Approval(
            originSender, spender,
            _storage.allowed(originSender, spender)
        );

        return true;
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param originSender the original transaction sender
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(
        address originSender,
        address account,
        uint256 value
    )
        internal
        returns (bool)
    {
        // Silence warnings
        originSender;

        require(account != 0);
        _storage.setTotalSupply(_storage.totalSupply().add(value));
        _storage.setBalance(account, _storage.balances(account).add(value));
        emit Transfer(address(0), account, value);

        return true;
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param originSender The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(
        address originSender,
        uint256 value
    )
        internal
        returns (bool)
    {
        require(originSender != 0);
        require(value <= _storage.balances(originSender));

        _storage.setTotalSupply(_storage.totalSupply().sub(value));
        _storage.setBalance(originSender, _storage.balances(originSender).sub(value));
        emit Transfer(originSender, address(0), value);

        return true;
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * @param originSender the original transaction sender
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(
        address originSender,
        address account,
        uint256 value
    )
        internal
        returns (bool)
    {
        require(value <= _storage.allowed(account, originSender));

        _storage .setAllowed(
            account, originSender,
            _storage.allowed(account, originSender).sub(value)
        );
        _burn(account, value);
        emit Approval(account, originSender, _storage.allowed(account, originSender));

        return true;
    }
}
