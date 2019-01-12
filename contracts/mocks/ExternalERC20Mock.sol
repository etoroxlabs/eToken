pragma solidity ^0.4.24;

import "../token/ERC20/ExternalERC20.sol";
import "../token/ERC20/ExternalERC20Storage.sol";

/**
 * @title External ERC20 mock contract
 * @dev Contract to test out currently unused functions for the
 * external ERC20
 */
contract ExternalERC20Mock is ExternalERC20 {

    constructor(address initialAccount, uint256 initialBalance)
        ExternalERC20(new ExternalERC20Storage())
        public
    {
        _externalERC20Storage.transferImplementor(this);
        _externalERC20Storage.transferOwnership(msg.sender);
        _mint(initialAccount, initialBalance);
    }

    /**
     * @dev mints given amount to given address
     * @param account address to be given
     * @param amount amount to be minted
     */
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    /**
     * @dev given address burns given amount
     * @param account address to be given
     * @param amount amount to be burned
     */
    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    /**
     * @dev message sender burns given amount from given address
     * @param account address to be given
     * @param amount amount to be burned
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(msg.sender, account, amount);
    }

    /**
     * @dev approve test function. Approves address to spend given amount
     * @param originSender address to approve spending
     * @param spender address to be approved
     * @param value amount to be approved
     */
    function approvePublicTest(
        address originSender,
        address spender,
        uint256 value
    )
        public
    {
        super._approve(originSender, spender, value);
    }

    /**
     * @dev transfer from test function
     * @param originSender address of sender
     * @param from address to be sent from
     * @param to address to be sent to
     * @param value value to be sent
     */
    function transferFromPublicTest(
        address originSender,
        address from,
        address to,
        uint256 value
    )
        public
    {
        super._transferFrom(
            originSender,
            from, to,
            value
        );
    }

    /**
     * @dev increase allowance test function
     * @param originSender address to increase allowance
     * @param spender address to get increased allowance
     * @param addedValue amount to increase by
     */
    function increaseAllowancePublicTest(
        address originSender,
        address spender,
        uint256 addedValue
    )
        public
    {
        super._increaseAllowance(originSender, spender, addedValue);
    }

    /**
     * @dev decrease allowance test function
     * @param originSender address to decrease allowance
     * @param spender address to have decreased allowance
     * @param subtractedValue amount to decrease by
     */
    function decreaseAllowancePublicTest(
        address originSender,
        address spender,
        uint256 subtractedValue
    )
        public
    {
        super._decreaseAllowance(originSender, spender, subtractedValue);
    }

    /**
     * @dev burn from test function
     * @param burner address to burn
     * @param account address to burn from
     * @param value amount to burn
     */
    function burnFromPublicTest(
        address burner,
        address account,
        uint256 value
    )
        public
    {
        super._burnFrom(burner, account, value);
    }

    /**
     * @dev internal approve function
     * @param originSender address to approve
     * @param spender address to be approved
     * @param value amount to be approved
     */
    function _approve(
        address originSender,
        address spender,
        uint256 value
    )
        internal
    {
        super._approve(originSender, spender, value);
    }

    /**
     * @dev internal transfer from function
     * @param originSender address of sender
     * @param from address to be sent from
     * @param to address to be sent to
     * @param value value to be sent
     */
    function _transferFrom(
        address originSender,
        address from,
        address to,
        uint256 value
    )
        internal
    {
        super._transferFrom(
            originSender,
            from, to,
            value
        );
    }

    /**
     * @dev increase allowance internal function
     * @param originSender address to increase allowance
     * @param spender address to get increased allowance
     * @param addedValue amount to increase by
     */
    function _increaseAllowance(
        address originSender,
        address spender,
        uint256 addedValue
    )
        internal
    {
        super._increaseAllowance(originSender, spender, addedValue);
    }

    /**
     * @dev decrease allowance internal function
     * @param originSender address to decrease allowance
     * @param spender address to have decreased allowance
     * @param subtractedValue amount to decrease by
     */
    function _decreaseAllowance(
        address originSender,
        address spender,
        uint256 subtractedValue
    )
        internal
    {
        super._decreaseAllowance(originSender, spender, subtractedValue);
    }

    /**
     * @dev internal transfer function
     * @param from address to be transferred from
     * @param to address to be transferred to
     * @param value amount to be transferred
     */
    function _transfer(address from, address to, uint256 value) internal {
        super._transfer(from, to, value);
    }

    /**
     * @dev internal minting function
     * @param account address to mint to
     * @param value amount to mint
     */
    function _mint(address account, uint256 value) internal {
        super._mint(account, value);
    }

    /**
     * @dev internal burn function
     * @param account address to burn from
     * @param value amount to burn
     */
    function _burn(address account, uint256 value) internal {
        super._burn(account, value);
    }

    /**
     * @dev internal burn from function
     * @param burner address to burn
     * @param account address to burn from
     * @param value amount to burn
     */
    function _burnFrom(
        address burner,
        address account,
        uint256 value
    )
        internal
    {
        super._burnFrom(burner, account, value);
    }
}
