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
import "./IUpgradableTokenX.sol";
/* solium-enable max-len */


contract TokenXExplicitSender is IUpgradableTokenX,
    ExternalERC20,
    ExternalERC20Burnable,
    ExternalERC20Mintable,
    ERC20Detailed,
    AccesslistGuarded,
    BurnerRole,
    Pausable
{

    /**
     * Holds the address of the
     */
    address private _upgradedFrom;

    bool private enabled;

    event UpgradeFinalized(address c, address sender);

    /**
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param accesslist Address of a deployed whitelist contract
     * @param externalERC20Storage Address of a deployed ERC20 storage contract
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
       @dev Called by the upgraded contract in order to mark the finalization of
       the upgrade and activate the new contract
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

    modifier isEnabled () {
        require(enabled, "Token disabled");
        _;
    }

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


    function burnExplicitSender(address sender, uint256 value)
        public
        isEnabled
        senderIsProxy
        requireBurner(sender)
    {
        super._burn(sender, value);
    }


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

    function mintExplicitSender(address sender, address to, uint256 value)
        public
        isEnabled
        senderIsProxy
        returns (bool success)
    {
        super._mintExplicitSender(sender, to, value);
        return true;
    }

    function changeMintingRecipientExplicitSender(address sender, address mintingRecip)
        public
        isEnabled
        senderIsProxy
    {
        super._changeMintingRecipient(sender, mintingRecip);
    }

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

    function burn(uint256 value) public isEnabled onlyBurner {
        super.burn(value);
    }

    function burnFrom(address from, uint256 value) public isEnabled onlyBurner {
        super.burnFrom(from, value);
    }

    function mint(address to, uint256 value)
        public
        isEnabled
        returns (bool)
    {
        super._mintExplicitSender(msg.sender, to, value);
        return true;
    }

    function changeMintingRecipient(address _mintingRecipientAddress)
        public
        isEnabled
        onlyOwner
    {
        super._changeMintingRecipient(msg.sender, _mintingRecipientAddress);
    }


}
