pragma solidity 0.4.24;

import "./Pausable.sol";
import "../ERC20/ERC20.sol";
import "./AccesslistGuarded.sol";
import "./roles/BurnerRole.sol";
import "./roles/MinterRole.sol";
import "./RestrictedMinter.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract ETokenGuarded is Pausable, ERC20, AccesslistGuarded, BurnerRole, MinterRole, RestrictedMinter {

    modifier requireOwner(address addr) {
        require(owner() == addr, "is not owner");
        _;
    }

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
        bool initialDeployment,
        address initialMintingRecipient
    )
        internal
        ERC20(name, symbol, decimals, externalStorage, initialDeployment, initialMintingRecipient)
        {
            RestrictedMinter(initialMintingRecipient);
        }

    /**
     * @dev Like EToken.name, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function nameGuarded(address sender)
        internal
        view
        returns(string)
    {
        // Silence warnings
        sender;
        return _name();
    }

    /**
     * @dev Like EToken.symbol, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function symbolGuarded(address sender)
        internal
        view
        returns(string)
    {
        // Silence warnings
        sender;
        return _symbol();
    }

    /**
     * @dev Like EToken.decimal, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function decimalsGuarded(address sender)
        internal
        view
        returns(uint8)
    {
        // Silence warnings
        sender;
        return _decimals();
    }

    /**
     * @dev Like EToken.totalSupply, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function totalSupplyGuarded(address sender)
        internal
        view
        returns(uint256)
    {
        sender;
        return _totalSupply();
    }

    /**
     * @dev Like EToken.balanceOf, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function balanceOfGuarded(address sender, address who)
        internal
        view
        returns(uint256)
    {
        // Silence warnings
        sender;
        return _balanceOf(who);
    }

    /**
     * @dev Like EToken.allowance, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function allowanceGuarded(address sender, address owner, address spender)
        internal
        view
        returns(uint256)
    {
        return _allowance(owner, spender);
    }

    /**
     * @dev Like EToken.transfer, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function transferGuarded(address sender, address to, uint256 value)
        internal
        whenNotPaused
        requireHasAccess(to)
        requireHasAccess(sender)
        returns (bool)
    {
        _transfer(sender, to, value);
        return true;
    }

    /**
     * @dev Like EToken.approve, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function approveGuarded(address sender, address spender, uint256 value)
        internal
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(sender)
        returns (bool)
    {
        _approve(sender, spender, value);
        return true;
    }


    /**
     * @dev Like EToken.transferFrom, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function transferFromGuarded(
        address sender,
        address from,
        address to,
        uint256 value
    )
        internal
        whenNotPaused
        requireHasAccess(from)
        requireHasAccess(to)
        requireHasAccess(sender)
        returns (bool)
    {
        _transferFrom(
            sender,
            from,
            to,
            value
        );
        return true;
    }


    /**
     * @dev Like EToken.increaseAllowance, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function increaseAllowanceGuarded(
        address sender,
        address spender,
        uint256 addedValue
    )
        internal
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(sender)
        returns (bool)
    {
        _increaseAllowance(sender, spender, addedValue);
        return true;
    }

    /**
     * @dev Like EToken.decreaseAllowance, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function decreaseAllowanceGuarded(address sender,
                                             address spender,
                                             uint256 subtractedValue)
        internal
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(sender)
        returns (bool)  {
        _decreaseAllowance(sender, spender, subtractedValue);
        return true;
    }

    /**
     * @dev Like EToken.burn, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function burnGuarded(address sender, uint256 value)
        internal
        requireBurner(sender)
    {
        _burn(sender, value);
    }

    /**
     * @dev Like EToken.burnFrom, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function burnFromGuarded(address sender,
                                    address from,
                                    uint256 value)
        internal
        requireBurner(sender)
    {
        _burnFrom(sender, from, value);
    }

    /**
     * @dev Like EToken.mint, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function mintGuarded(address sender, address to, uint256 value)
        internal
        requireMinter(sender)
        requireMintingRecipient(to)
        returns (bool success)
    {
        _mint(sender, to, value);
        return true;
    }

    /**
     * @dev Like EToken.changeMintingRecipient, but gets sender from
     * explicit sender parameter rather than msg.sender. This function
     * can only be called from the proxy contract (the contract that
     * this contract upgraded).
     */
    function changeMintingRecipientGuarded(address sender, address mintingRecip)
        requireOwner(sender)
        internal
    {
        _changeMintingRecipient(sender, mintingRecip);
    }

    function pausedGuarded(address sender)
        external
    {
        // Silence warnings
        sender;
        _paused();
    }

}
