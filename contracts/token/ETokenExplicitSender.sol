pragma solidity 0.4.24;

/* solium-disable max-len */
import "./ERC20/ExternalERC20Storage.sol";
import "./ERC20/ExternalERC20.sol";
import "./ERC20/ExternalERC20Burnable.sol";
import "./ERC20/ExternalERC20Mintable.sol";
import "../lifecycle/Pausable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "../access/roles/BurnerRole.sol";
import "../access/Accesslist.sol";
import "../access/AccesslistGuarded.sol";
import "./IUpgradableEToken.sol";
/* solium-enable max-len */

/** @title EToken functions accepting explicit sender params */
contract ETokenExplicitSender is IUpgradableEToken,
    ExternalERC20,
    ExternalERC20Burnable,
    ExternalERC20Mintable,
    ERC20Detailed,
    AccesslistGuarded,
    BurnerRole,
    Pausable
{

    /**
     * @dev Holds the address of the contract that was upgraded from
     */
    address private _upgradedFrom;

    bool private enabled;

    event UpgradeFinalized(address indexed upgradedFrom);

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
    function finalizeUpgrade()
        external
        senderIsProxy
    {
        enabled = true;
        emit UpgradeFinalized(msg.sender);
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
     * @dev Like EToken.name, but gets sender from explicit sender
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
     * @dev Like EToken.symbol, but gets sender from explicit sender
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
     * @dev Like EToken.decimal, but gets sender from explicit sender
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
     * @dev Like EToken.totalSupply, but gets sender from explicit sender
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
     * @dev Like EToken.balanceOf, but gets sender from explicit sender
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
     * @dev Like EToken.allowance, but gets sender from explicit sender
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
     * @dev Like EToken.transfer, but gets sender from explicit sender
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
     * @dev Like EToken.approve, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function approveExplicitSender(address sender, address spender, uint256 value)
        public
        isEnabled
        senderIsProxy
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(sender)
        returns (bool)
    {
        super._approve(sender, spender, value);
        return true;
    }


    /**
     * @dev Like EToken.transferFrom, but gets sender from explicit sender
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
     * @dev Like EToken.increaseAllowance, but gets sender from explicit sender
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
     * @dev Like EToken.decreaseAllowance, but gets sender from explicit sender
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
     * @dev Like EToken.burn, but gets sender from explicit sender
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
     * @dev Like EToken.burnFrom, but gets sender from explicit sender
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
     * @dev Like EToken.mint, but gets sender from explicit sender
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
     * @dev Like EToken.changeMintingRecipient, but gets sender from
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
     * @dev Like EToken.transfer. Transfers tokens to a specified address
     * @param to The address to transfer to
     * @param value the amount to be transferred
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
     * @dev Like EToken.approve. Approves passed address to spend specified
     * @dev amount on their behalf
     * @param spender The address which will spend the funds
     * @param value The amount of tokens to be spent.
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
     * @dev Like EToken.transferFrom. Transfers tokens from one address to another
     * @param from The address to send tokens from
     * @param to The address to transfer to
     * @param value the amount of tokens to be transferred 
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
     * @dev Like EToken.increaseAllowance. Increase the amount of tokens spender
     * @dev is allowed to spend
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
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
     * @dev Like EToken.decreaseAllowance. Decrease the amount of tokens allowed
     * @dev to spender
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
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

    /** @dev Burning function called by EToken.burn */
    function burn(uint256 value) public isEnabled onlyBurner {
        super.burn(value);
    }

    /** @dev Burning function called by EToken.burnFrom */
    function burnFrom(address from, uint256 value) public isEnabled onlyBurner {
        super.burnFrom(from, value);
    }

    /** @dev Minting function called by EToken.mint */
    function mint(address to, uint256 value)
        public
        isEnabled
        returns (bool)
    {
        super._mintExplicitSender(msg.sender, to, value);
        return true;
    }

    /** @dev changeMintingRecipient function called by EToken.changeMintingRecipient */
    function changeMintingRecipient(address _mintingRecipientAddress)
        public
        isEnabled
        onlyOwner
    {
        super._changeMintingRecipient(msg.sender, _mintingRecipientAddress);
    }


}
