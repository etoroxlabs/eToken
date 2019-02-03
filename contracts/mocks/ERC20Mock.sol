pragma solidity 0.4.24;

import "../token/ERC20/ERC20.sol";
import "../token/ERC20/Storage.sol";

/**
 * @title External ERC20 mock contract
 * @dev Contract to test out currently unused functions for the
 * external ERC20
 */
contract ERC20Mock is ERC20 {

    constructor(
        address initialAccount, uint256 initialBalance,
        Storage _storage, bool isInitialDeployment
    )
        ERC20("test", "te", 4, _storage, isInitialDeployment)
        public
    {
        if (initialBalance != 0) {
            _mint(initialAccount, initialBalance);
        }
    }

    function name() public view returns(string) {
        return _name();
    }

    function symbol() public view returns(string) {
        return _symbol();
    }

    function decimals() public view returns(uint8) {
        return _decimals();
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply();
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balanceOf(owner);
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowance(owner, spender);
    }

    function transfer(address to, uint256 value)
        public
        returns (bool)
    {
        return _transfer(msg.sender, to, value);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        return _approve(msg.sender, spender, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        returns (bool)
    {
        return _transferFrom(
            msg.sender,
            from,
            to,
            value
        );
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        return _increaseAllowance(msg.sender, spender, addedValue);
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
        public
        returns (bool)
    {
        return _decreaseAllowance(msg.sender, spender, subtractedValue);
    }

    function mint(
        address account,
        uint256 value
    )
        public
        returns (bool)
    {
        return _mint(account, value);
    }

    function burn(
        address from,
        uint256 value
    )
        public
        returns (bool)
    {
        return super._burn(from, value);
    }

    function burnFrom(
        address account,
        uint256 value
    )
        public
        returns (bool)
    {
        return _burnFrom(msg.sender, account, value);
    }

    function approvePublicTest(
        address originSender,
        address spender,
        uint256 value
    )
        public
        returns (bool)
    {
        return _approve(originSender, spender, value);
    }

    function increaseAllowancePublicTest(
        address originSender,
        address spender,
        uint256 addedValue
    )
        public
        returns (bool)
    {
        return _increaseAllowance(originSender, spender, addedValue);
    }

    function decreaseAllowancePublicTest(
        address originSender,
        address spender,
        uint256 subtractedValue
    )
        public
        returns (bool)
    {
        return _decreaseAllowance(originSender, spender, subtractedValue);
    }

    function burnFromPublicTest(
        address originSender,
        address account,
        uint256 value
    )
        public
        returns (bool)
    {
        return _burnFrom(originSender, account, value);
    }

    function transferFromPublicTest(
        address originSender,
        address from,
        address to,
        uint256 value
    )
        public
        returns (bool)
    {
        return _transferFrom(originSender, from, to, value);
    }
}
