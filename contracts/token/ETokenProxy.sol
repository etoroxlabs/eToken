pragma solidity 0.4.24;

import "./IETokenProxy.sol";
import "./UpgradeSupport.sol";
import "./access/ETokenGuarded.sol";

/**
 * For every call recieved the following takes place:
 * If this token is upgraded, all calls are being 
 */
contract ETokenProxy is IETokenProxy, ETokenGuarded {

    /**
     * @dev Constructor
     * @param name The ERC20 detailed token name
     * @param symbol The ERC20 detailed symbol name
     * @param decimals Determines the number of decimals of this token
     * @param accesslist Address of a deployed whitelist contract
     * @param whitelistEnabled Create token with whitelist enabled
     * @param externalStorage The external storage contract.
     * Should be zero address if shouldCreateStorage is true.
     * @param initialDeployment Set to true if this is the initial deployment of
     * the token. If true it automtically creates a new ExternalERC20Storage.
     * Also, it acts as a confirmation of intention which interlocks
     * upgradedFrom as follows: If initialDeployment is true, then
     * upgradedFrom must be the zero address. Otherwise, upgradedFrom must not
     * be the zero address. The same applies to externalERC20Storage, which must
     * be set to the zero address if initialDeployment is true.
     * @param upgradedFrom The token contract that this contract upgrades. Set
     * to address(0) for initial deployments
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        Storage externalStorage,
        address initialMintingRecipient,
        address upgradedFrom,
        bool initialDeployment
    )
        internal
        UpgradeSupport(initialDeployment, upgradedFrom)
        ETokenGuarded(name, symbol, decimals,
                      accesslist, whitelistEnabled,
                      externalStorage, initialMintingRecipient,
                      initialDeployment)
    {

    }

    /** Like EToken.name but proxies calls as described in the
        documentation for the declaration of this contract. */
    function nameProxy(address sender)
        external
        view
        isEnabled
        onlyProxy
        returns(string)
    {
        if (isUpgraded()) {
            return upgradedToken.nameProxy(sender);
        } else {
            return nameGuarded(sender);
        }
    }

    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function symbolProxy(address sender)
        external
        view
        isEnabled
        onlyProxy
        returns(string)
    {
        if (isUpgraded()) {
            return upgradedToken.symbolProxy(sender);
        } else {
            return symbolGuarded(sender);
        }
    }

    /** Like EToken.decimals but proxies calls as described in the
        documentation for the declaration of this contract. */
    function decimalsProxy(address sender)
        external
        view
        isEnabled
        onlyProxy
        returns(uint8)
    {
        if (isUpgraded()) {
            return upgradedToken.decimalsProxy(sender);
        } else {
            return decimalsGuarded(sender);
        }
    }

    /* Taken from IERC20 in openzeppelin-solidity */
    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function totalSupplyProxy(address sender)
        external
        view
        isEnabled
        onlyProxy
        returns (uint256)
    {
        if (isUpgraded()) {
            upgradedToken.totalSupplyProxy(sender);
        } else {
            totalSupplyGuarded(sender);
        }
    }

    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function balanceOfProxy(address sender, address who)
        external
        view
        isEnabled
        onlyProxy
        returns (uint256)
    {
        if (isUpgraded()) {
            return upgradedToken.balanceOfProxy(sender, who);
        } else {
            return balanceOfGuarded(sender, who);
        }
    }

    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function allowanceProxy(address sender,
                            address owner,
                            address spender)
        external
        view
        isEnabled
        onlyProxy
        returns (uint256)
    {
        if (isUpgraded()) {
            return upgradedToken.allowanceProxy(sender, owner, spender);
        } else {
            return allowanceGuarded(sender, owner, spender);
        }
    }


    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function transferProxy(address sender, address to, uint256 value)
        external
        isEnabled
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            return upgradedToken.transferProxy(sender, to, value);
        } else {
            return transferGuarded(sender, to, value);
        }

    }

    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function approveProxy(address sender,
                          address spender,
                          uint256 value)
        external
        isEnabled
        onlyProxy
        returns (bool)
    {

        if (isUpgraded()) {
            return upgradedToken.approveProxy(sender, spender, value);
        } else {
            return approveGuarded(sender, spender, value);
        }
    }

    /** Like EToken.symbol but proxies calls as described in the
        documentation for the declaration of this contract. */
    function transferFromProxy(address sender,
                               address from,
                               address to,
                               uint256 value)
        external
        isEnabled
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            upgradedToken.transferFromProxy(sender,
                                            from,
                                            to,
                                            value);
        } else {
            transferFromGuarded(sender,
                                from,
                                to,
                                value);
        }
    }

    /** Like EToken. but proxies calls as described in the
        documentation for the declaration of this contract. */
    function mintProxy(address sender, address to, uint256 value)
        external
        isEnabled
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            return upgradedToken.mintProxy(sender, to, value);
        } else {
            return mintGuarded(sender, to, value);
        }
    }

    /** Like EToken.changeMintingRecipient but proxies calls as
        described in the documentation for the declaration of this
        contract. */
    function changeMintingRecipientProxy(address sender,
                                         address mintingRecip)
        external
        isEnabled
        onlyProxy
    {
        if (isUpgraded()) {
            upgradedToken.changeMintingRecipientProxy(sender, mintingRecip);
        } else {
            changeMintingRecipientGuarded(sender, mintingRecip);
        }
    }

    /** Like EToken.burn but proxies calls as described in the
        documentation for the declaration of this contract. */
    function burnProxy(address sender, uint256 value)
        external
        isEnabled
        onlyProxy
    {
        if (isUpgraded()) {
            upgradedToken.burnProxy(sender, value);
        } else {
            burnGuarded(sender, value);
        }
    }

    /** Like EToken.burnFrom but proxies calls as described in the
        documentation for the declaration of this contract. */
    function burnFromProxy(address sender,
                           address from,
                           uint256 value)
        external
        isEnabled
        onlyProxy
    {
        if (isUpgraded()) {
            upgradedToken.burnFromProxy(sender, from, value);
        } else {
            burnFromGuarded(sender, from, value);
        }
    }

    /** Like EToken.increaseAllowance but proxies calls as described
        in the documentation for the declaration of this contract. */
    function increaseAllowanceProxy(address sender,
                                    address spender,
                                    uint addedValue)
        external
        isEnabled
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            return upgradedToken.increaseAllowanceProxy(sender, spender, addedValue);
        } else {
            return increaseAllowanceGuarded(sender, spender, addedValue);
        }
    }

    /** Like EToken.decreaseAllowance but proxies calls as described
        in the documentation for the declaration of this contract. */
    function decreaseAllowanceProxy(address sender,
                                    address spender,
                                    uint subtractedValue)
        external
        isEnabled
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            return upgradedToken.decreaseAllowanceProxy(sender, spender, subtractedValue);
        } else {
            return decreaseAllowanceGuarded(sender, spender, subtractedValue);
        }
    }

}
