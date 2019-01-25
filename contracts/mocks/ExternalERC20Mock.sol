pragma solidity 0.4.24;

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
     * @dev Mints amount to given address
     * @param account Receiving address
     * @param amount Amount to be minted
     */
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    /**
     * @dev Burn amount from the given address
     * @param account Address to burn from
     * @param amount Amount to be burned
     */
    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    /**
     * @dev Message sender burns approved amount from the given address
     * @param account Address to burn from
     * @param amount Amount to be burned
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(msg.sender, account, amount);
    }

    /**
     * @dev Approve test function. Approves the given address to spend amount.
     * @param originSender Address that approves spending
     * @param spender Address to be approved
     * @param value Amount to be approved
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
     * @dev Transfer from test function
     * @param originSender Address of sender
     * @param from Address to be sent from
     * @param to Address to be sent to
     * @param value Amount to be sent
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
     * @dev Increase allowance test function
     * @param originSender Address to increase allowance
     * @param spender Address to get increased allowance
     * @param addedValue Amount to increase by
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
     * @dev Decrease allowance test function
     * @param originSender Address to decrease allowance
     * @param spender Address to have decreased allowance
     * @param subtractedValue Amount to decrease by
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

    /** Causes compilation errors if _approve function is not declared internal */
    function _approve(
        address originSender,
        address spender,
        uint256 value
    )
        internal
    {
        super._approve(originSender, spender, value);
    }

    /** Causes compilation errors if _transferFrom function is not declared internal */
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

    /** Causes compilation errors if _increaseAllowance function is not declared internal */
    function _increaseAllowance(
        address originSender,
        address spender,
        uint256 addedValue
    )
        internal
    {
        super._increaseAllowance(originSender, spender, addedValue);
    }

    /** Causes compilation errors if _decreaseAllowance function is not declared internal */
    function _decreaseAllowance(
        address originSender,
        address spender,
        uint256 subtractedValue
    )
        internal
    {
        super._decreaseAllowance(originSender, spender, subtractedValue);
    }

    /** Causes compilation errors if _transfer function is not declared internal */
    function _transfer(address from, address to, uint256 value) internal {
        super._transfer(from, to, value);
    }

    /** Causes compilation errors if _mint function is not declared internal */
    function _mint(address account, uint256 value) internal {
        super._mint(account, value);
    }

    /** Causes compilation errors if _burn function is not declared internal */
    function _burn(address account, uint256 value) internal {
        super._burn(account, value);
    }

    /** Causes compilation errors if _burnFrom function is not declared internal */
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
