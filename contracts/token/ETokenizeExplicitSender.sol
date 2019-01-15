pragma solidity ^0.4.24;

/* solium-disable max-len */
import "./ERC20/ExternalERC20Storage.sol";
import "./ERC20/ExternalERC20.sol";
import "./ERC20/ExternalERC20Burnable.sol";
import "./ERC20/ExternalERC20Mintable.sol";
import "../lifecycle/Pausable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "../access/roles/BurnerRole.sol";
import "../access/roles/MinterRole.sol";
import "../access/Accesslist.sol";
import "../access/AccesslistGuarded.sol";
import "./IUpgradableETokenize.sol";
/* solium-enable max-len */

/** @title TokenX functions accepting explicit sender params */
contract ETokenizeExplicitSender is IUpgradableETokenize,
    ExternalERC20,
    ExternalERC20Burnable,
    ExternalERC20Mintable,
    ERC20Detailed,
    AccesslistGuarded,
    BurnerRole,
    Pausable
{

    /**
     * @dev Holds the address of the
     */
    address private _upgradedFrom;

    bool private enabled;

    event UpgradeFinalized(address indexed upgradedFrom, address indexed sender);

    /**
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param decimals The number of decimals of the token
     * @param accesslist Address of a deployed whitelist contract
     * @param whitelistEnabled Create token with whitelist enabled
     * @param externalERC20Storage Address of a deployed ERC20 storage contract
     * @param mintingRecipientAccount The initial minting recipient of the token
     * @param upgradedFrom The token contract that this contract upgrades. Set
     * to address(0) for initial deployments
     * @param initialDeployment Set to true if this is the initial deployment of
     * the token. Acts as a confirmation of intention which interlocks
     * upgradedFrom as follows: If initialDeployment is true, then
     * upgradedFrom must be the zero address. Otherwise, upgradedFrom must not
     * be the zero address.
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        ExternalERC20Storage externalERC20Storage,
        address mintingRecipientAccount,
        address upgradedFrom,
        bool initialDeployment
    )
        internal
        ExternalERC20(externalERC20Storage)
        ExternalERC20Mintable(mintingRecipientAccount)
        ERC20Detailed(name, symbol, decimals)
        AccesslistGuarded(accesslist, whitelistEnabled)
    {

        require((upgradedFrom != address(0) && (! initialDeployment)) ||
                (upgradedFrom == address(0) && initialDeployment),
                "Cannot both be upgraded and initial deployment.");

        if (! initialDeployment) {
            // Pause until explicitly unpaused by upgraded contract
            enabled = false;
            _upgradedFrom = upgradedFrom;
        } else {
            enabled = true;
        }
    }

    /**
     * @dev Called by the upgraded contract in order to mark the finalization of
     * the upgrade and activate the new contract
     */
    function finalizeUpgrade() external {
        require(_upgradedFrom != address(0), "Must have a contract to upgrade from");
        require(msg.sender == _upgradedFrom, "Sender is not old contract");
        enabled = true;
        emit UpgradeFinalized(_upgradedFrom, msg.sender);
    }

    /**
     * @dev Only allow the old contract to access the functions with explicit
     * sender passing
     */
    modifier senderIsProxy () {
        require(msg.sender == _upgradedFrom, "Proxy is the only allowed caller");
        _;
    }

    /**
     * @dev Allows execution if token is enabled, i.e. it is the
     * initial deployment or is upgraded from a contract which has
     * called the finalizeUpgrade function.
     */
    modifier isEnabled () {
        require(enabled, "Token disabled");
        _;
    }

    /**
     * @dev Like TokenX.name, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function nameExplicitSender(address sender)
        public
        view
        isEnabled
        senderIsProxy
        returns(string)
    {
        // Silence warnings
        sender;
        return super.name();
    }

    /**
     * @dev Like TokenX.symbol, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function symbolExplicitSender(address sender)
        public
        view
        isEnabled
        senderIsProxy
        returns(string)
    {
        // Silence warnings
        sender;
        return super.symbol();
    }

    /**
     * @dev Like TokenX.decimal, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function decimalsExplicitSender(address sender)
        public
        view
        isEnabled
        senderIsProxy
        returns(uint8)
    {
        // Silence warnings
        sender;
        return super.decimals();
    }

    /**
     * @dev Like TokenX.totalSupply, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function totalSupplyExplicitSender(address sender)
        public
        view
        isEnabled
        senderIsProxy
        returns(uint256)
    {
        // Silence warnings
        sender;
        return super.totalSupply();
    }

    /**
     * @dev Like TokenX.balanceOf, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function balanceOfExplicitSender(address sender, address who)
        public
        view
        isEnabled
        senderIsProxy
        returns(uint256)
    {
        // Silence warnings
        sender;
        return super.balanceOf(who);
    }

    /**
     * @dev Like TokenX.allowance, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function allowanceExplicitSender(address sender, address owner, address spender)
        public
        view
        isEnabled
        senderIsProxy
        returns(uint256)
    {
        // Silence warnings
        sender;
        return super.allowance(owner, spender);
    }

    /**
     * @dev Like TokenX.transfer, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function transferExplicitSender(address sender, address to, uint256 value)
        public
        isEnabled
        senderIsProxy
        whenNotPaused
        requireHasAccess(to)
        requireHasAccess(sender)
        returns (bool)
    {
        super._transfer(sender, to, value);
        return true;
    }

    /**
     * @dev Like TokenX.approve, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function approveExplicitSender(address sender, address spender, uint256 value)
        public
        isEnabled
        senderIsProxy
        whenNotPaused
        // FIXME: This used to be spender spender. Why wasn't this caught in tests?
        requireHasAccess(spender)
        requireHasAccess(sender)
        returns (bool)
    {
        super._approve(sender, spender, value);
        return true;
    }


    /**
     * @dev Like TokenX.transferFrom, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function transferFromExplicitSender(
        address sender,
        address from,
        address to,
        uint256 value
    )
        public
        isEnabled
        senderIsProxy
        whenNotPaused
        requireHasAccess(from)
        requireHasAccess(to)
        requireHasAccess(sender)
        returns (bool)
    {
        super._transferFrom(sender,
                            from,
                            to,
                            value);
        return true;
    }


    /**
     * @dev Like TokenX.increaseAllowance, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function increaseAllowanceExplicitSender(
        address sender,
        address spender,
        uint256 addedValue
    )
        public
        isEnabled
        senderIsProxy
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(sender)
        returns (bool)
    {
        super._increaseAllowance(sender, spender, addedValue);
        return true;
    }

    /**
     * @dev Like TokenX.decreaseAllowance, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function decreaseAllowanceExplicitSender(address sender,
                                             address spender,
                                             uint256 subtractedValue)
        public
        isEnabled
        senderIsProxy
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(sender)
        returns (bool)  {
        super._decreaseAllowance(sender, spender, subtractedValue);
        return true;
    }

    /**
     * @dev Like TokenX.burn, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function burnExplicitSender(address sender, uint256 value)
        public
        isEnabled
        senderIsProxy
        requireBurner(sender)
    {
        super._burn(sender, value);
    }

    /**
     * @dev Like TokenX.burnFrom, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function burnFromExplicitSender(address sender,
                                    address from,
                                    uint256 value)
        public
        isEnabled
        senderIsProxy
        requireBurner(sender)
    {
        super._burnFrom(sender, from, value);
    }

    /**
     * @dev Like TokenX.mint, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function mintExplicitSender(address sender, address to, uint256 value)
        public
        isEnabled
        senderIsProxy
        returns (bool success)
    {
        super._mintExplicitSender(sender, to, value);
        return true;
    }

    /**
     * @dev Like TokenX.changeMintingRecipient, but gets sender from
     * explicit sender parameter rather than msg.sender. This function
     * can only be called from the proxy contract (the contract that
     * this contract upgraded).
     */
    function changeMintingRecipientExplicitSender(address sender, address mintingRecip)
        public
        isEnabled
        senderIsProxy
    {
        super._changeMintingRecipient(sender, mintingRecip);
    }

    /**
     * @dev Like TokenX.transfer, but gets sender from
     * explicit sender parameter rather than msg.sender. This function
     * can only be called from the proxy contract (the contract that
     * this contract upgraded).
     */
    function transfer(address to, uint256 value)
        public
        isEnabled
        whenNotPaused
        requireHasAccess(to)
        onlyHasAccess
        returns (bool)
    {
        return super.transfer(to, value);
    }

    /**
     * @dev Like TokenX.approve, but gets sender from
     * explicit sender parameter rather than msg.sender. This function
     * can only be called from the proxy contract (the contract that
     * this contract upgraded).
     */
    function approve(address spender, uint256 value)
        public
        isEnabled
        whenNotPaused
        requireHasAccess(spender)
        onlyHasAccess
        returns (bool)
    {
        return super.approve(spender, value);
    }

    /**
     * @dev Like TokenX.transferFrom, but gets sender from
     * explicit sender parameter rather than msg.sender. This function
     * can only be called from the proxy contract (the contract that
     * this contract upgraded).
     */
    function transferFrom(address from, address to, uint256 value)
        public
        isEnabled
        whenNotPaused
        requireHasAccess(from)
        requireHasAccess(to)
        onlyHasAccess
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

    /**
     * @dev Like TokenX.increaseAllowance, but gets sender from
     * explicit sender parameter rather than msg.sender. This function
     * can only be called from the proxy contract (the contract that
     * this contract upgraded).
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        isEnabled
        whenNotPaused
        requireHasAccess(spender)
        onlyHasAccess
        returns (bool)
    {
        return super.increaseAllowance(spender, addedValue);
    }

    /**
     * @dev Like TokenX.decreaseAllowance, but gets sender from
     * explicit sender parameter rather than msg.sender. This function
     * can only be called from the proxy contract (the contract that
     * this contract upgraded).
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        isEnabled
        whenNotPaused
        requireHasAccess(spender)
        onlyHasAccess
        returns (bool)
    {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    /** @dev Burning function called by TokenX.burn */
    function burn(uint256 value) public isEnabled onlyBurner {
        super.burn(value);
    }

    /** @dev Burning function called by TokenX.burnFrom */
    function burnFrom(address from, uint256 value) public isEnabled onlyBurner {
        super.burnFrom(from, value);
    }

    /** @dev Minting function called by TokenX.mint */
    function mint(address to, uint256 value)
        public
        isEnabled
        returns (bool)
    {
        super._mintExplicitSender(msg.sender, to, value);
        return true;
    }

    /** @dev changeMintingRecipient function called by TokenX.changeMintingRecipient */
    function changeMintingRecipient(address _mintingRecipientAddress)
        public
        isEnabled
        onlyOwner
    {
        super._changeMintingRecipient(msg.sender, _mintingRecipientAddress);
    }


}
