pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./Pausable.sol";
import "../ERC20/ERC20.sol";
import "./AccesslistGuarded.sol";
import "./Accesslist.sol";
import "./roles/BurnerRole.sol";
import "./roles/MinterRole.sol";
import "./RestrictedMinter.sol";
import "./../UpgradeSupport.sol";

contract ETokenGuarded is
    Pausable,
    ERC20,
    UpgradeSupport,
    AccesslistGuarded,
    BurnerRole,
    MinterRole,
    RestrictedMinter
{

    modifier requireOwner(address addr) {
        require(owner() == addr, "is not owner");
        _;
    }

    /**
     * @dev Constructor
     * @param name The ERC20 detailed token name
     * @param symbol The ERC20 detailed symbol name
     * @param decimals Determines the number of decimals of this token
     * @param accesslist Address of a deployed whitelist contract
     * @param whitelistEnabled Create token with whitelist enabled
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
        Accesslist accesslist,
        bool whitelistEnabled,
        Storage externalStorage,
        address initialMintingRecipient,
        bool initialDeployment
    )
        internal
        ERC20(name, symbol, decimals, externalStorage, initialDeployment)
        AccesslistGuarded(accesslist, whitelistEnabled)
        RestrictedMinter(initialMintingRecipient)
    {

    }

    /**
     * @dev Like EToken.name, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function nameGuarded(address originSender)
        internal
        view
        returns(string)
    {
        // Silence warnings
        originSender;

        return _name();
    }

    /**
     * @dev Like EToken.symbol, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function symbolGuarded(address originSender)
        internal
        view
        returns(string)
    {
        // Silence warnings
        originSender;

        return _symbol();
    }

    /**
     * @dev Like EToken.decimal, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function decimalsGuarded(address originSender)
        internal
        view
        returns(uint8)
    {
        // Silence warnings
        originSender;

        return _decimals();
    }

    /**
     * @dev Like EToken.totalSupply, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function totalSupplyGuarded(address originSender)
        internal
        view
        isEnabled
        returns(uint256)
    {
        // Silence warnings
        originSender;

        return _totalSupply();
    }

    /**
     * @dev Like EToken.balanceOf, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function balanceOfGuarded(address originSender, address who)
        internal
        view
        isEnabled
        returns(uint256)
    {
        // Silence warnings
        originSender;

        return _balanceOf(who);
    }

    /**
     * @dev Like EToken.allowance, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function allowanceGuarded(
        address originSender,
        address owner,
        address spender
    )
        internal
        view
        isEnabled
        returns(uint256)
    {
        // Silence warnings
        originSender;

        return _allowance(owner, spender);
    }

    /**
     * @dev Like EToken.transfer, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function transferGuarded(address originSender, address to, uint256 value)
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(to)
        requireHasAccess(originSender)
        returns (bool)
    {
        _transfer(originSender, to, value);
        return true;
    }

    /**
     * @dev Like EToken.approve, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function approveGuarded(
        address originSender,
        address spender,
        uint256 value
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(originSender)
        returns (bool)
    {
        _approve(originSender, spender, value);
        return true;
    }


    /**
     * @dev Like EToken.transferFrom, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function transferFromGuarded(
        address originSender,
        address from,
        address to,
        uint256 value
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(originSender)
        requireHasAccess(from)
        requireHasAccess(to)
        returns (bool)
    {
        _transferFrom(
            originSender,
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
        address originSender,
        address spender,
        uint256 addedValue
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(originSender)
        requireHasAccess(spender)
        returns (bool)
    {
        _increaseAllowance(originSender, spender, addedValue);
        return true;
    }

    /**
     * @dev Like EToken.decreaseAllowance, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function decreaseAllowanceGuarded(
        address originSender,
        address spender,
        uint256 subtractedValue
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(originSender)
        requireHasAccess(spender)
        returns (bool)  {
        _decreaseAllowance(originSender, spender, subtractedValue);
        return true;
    }

    /**
     * @dev Like EToken.burn, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function burnGuarded(address originSender, uint256 value)
        internal
        isEnabled
        requireBurner(originSender)
    {
        _burn(originSender, value);
    }

    /**
     * @dev Like EToken.burnFrom, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function burnFromGuarded(address originSender, address from, uint256 value)
        internal
        isEnabled
        requireBurner(originSender)
    {
        _burnFrom(originSender, from, value);
    }

    /**
     * @dev Like EToken.mint, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function mintGuarded(address originSender, address to, uint256 value)
        internal
        isEnabled
        requireMinter(originSender)
        requireMintingRecipient(to)
        returns (bool success)
    {
        // Silence warnings
        originSender;

        _mint(to, value);
        return true;
    }

    /**
     * @dev Like EToken.changeMintingRecipient, but gets sender from
     * explicit sender parameter rather than msg.sender. This function
     * can only be called from the proxy contract (the contract that
     * this contract upgraded).
     */
    function changeMintingRecipientGuarded(
        address originSender,
        address mintingRecip
    )
        internal
        isEnabled
        requireOwner(originSender)
    {
        _changeMintingRecipient(originSender, mintingRecip);
    }

    function pauseGuarded(address originSender)
        internal
        isEnabled
        requireOwner(originSender)
    {
        _pause();
    }

    function unpauseGuarded(address originSender)
        internal
        isEnabled
        requireOwner(originSender)
    {
        _unpause();
    }

    function pausedGuarded(address originSender)
        internal
        view
        returns (bool)
    {
        // Silence warnings
        originSender;
        return _paused();
    }

}
