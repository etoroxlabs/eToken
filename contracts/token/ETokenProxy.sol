pragma solidity 0.4.24;

import "./IETokenProxy.sol";
import "./ETokenUpgrade.sol";
import "./access/ETokenGuarded.sol";

contract ETokenProxy is IETokenProxy, ETokenUpgrade, ETokenGuarded {

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
        bool initialDeployment,
        address upgradedFrom
    )
        internal
        ETokenUpgrade(initialDeployment, upgradedFrom)
        ETokenGuarded(name, symbol, decimals,
                      accesslist, whitelistEnabled,
                      externalStorage, initialMintingRecipient,
                      initialDeployment)
    {

    }

    /* Taken from ERC20Detailed in openzeppelin-solidity */
    function nameProxy(address sender)
        external
        view
        onlyProxy
        returns(string)
    {
        if (isUpgraded()) {
            upgradedToken.nameProxy(sender);
        } else {
            nameGuarded(sender);
        }
    }

    function symbolProxy(address sender)
        external
        view
        onlyProxy
        returns(string)
    {
        if (isUpgraded()) {
            upgradedToken.symbolProxy(sender);
        } else {
            symbolGuarded(sender);
        }
    }

    function decimalsProxy(address sender)
        external
        view
        onlyProxy
        returns(uint8)
    {
        if (isUpgraded()) {
            upgradedToken.decimalsProxy(sender);
        } else {
            decimalsGuarded(sender);
        }
    }

    /* Taken from IERC20 in openzeppelin-solidity */
    function totalSupplyProxy(address sender)
        external
        view
        onlyProxy
        returns (uint256)
    {
        if (isUpgraded()) {
            upgradedToken.totalSupplyProxy(sender);
        } else {
            totalSupplyGuarded(sender);
        }
    }

    function balanceOfProxy(address sender, address who)
        external
        view
        onlyProxy
        returns (uint256)
    {
        if (isUpgraded()) {
            upgradedToken.balanceOfProxy(sender, who);
        } else {
            balanceOfGuarded(sender, who);
        }
    }

    function allowanceProxy(address sender,
                            address owner,
                            address spender)
        external
        view
        onlyProxy
        returns (uint256)
    {
        if (isUpgraded()) {
            upgradedToken.allowanceProxy(sender, owner, spender);
        } else {
            allowanceGuarded(sender, owner, spender);
        }
    }


    function transferProxy(address sender, address to, uint256 value)
        external
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            upgradedToken.transferProxy(sender, to, value);
        } else {
            transferGuarded(sender, to, value);
        }

    }

    function approveProxy(address sender,
                          address spender,
                          uint256 value)
        external
        onlyProxy
        returns (bool)
    {

        if (isUpgraded()) {
            upgradedToken.approveProxy(sender, spender, value);
        } else {
            approveGuarded(sender, spender, value);
        }
    }

    function transferFromProxy(address sender,
                               address from,
                               address to,
                               uint256 value)
        external
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            upgradedToken.transferFromProxy(sender, from, to, value);
        } else {
            transferFromGuarded(sender, from, to, value);
        }
    }

    function mintProxy(address sender, address to, uint256 value)
        external
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            upgradedToken.mintProxy(sender, to, value);
        } else {
            mintGuarded(sender, to, value);
        }
    }

    function changeMintingRecipientProxy(address sender,
                                         address mintingRecip)
        external
        onlyProxy
    {
        if (isUpgraded()) {
            upgradedToken.changeMintingRecipientProxy(sender, mintingRecip);
        } else {
            changeMintingRecipientGuarded(sender, mintingRecip);
        }
    }

    function burnProxy(address sender, uint256 value) external {
        if (isUpgraded()) {
            upgradedToken.burnProxy(sender, value);
        } else {
            burnGuarded(sender, value);
        }
    }

    function burnFromProxy(address sender,
                           address from,
                           uint256 value)
        external
        onlyProxy
    {
        if (isUpgraded()) {
            upgradedToken.burnFromProxy(sender, from, value);
        } else {
            burnFromGuarded(sender, from, value);
        }
    }

    function increaseAllowanceProxy(address sender,
                                    address spender,
                                    uint addedValue)
        external
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            upgradedToken.increaseAllowanceProxy(sender, spender, addedValue);
        } else {
            increaseAllowanceGuarded(sender, spender, addedValue);
        }
    }

    function decreaseAllowanceProxy(address sender,
                                    address spender,
                                    uint subtractedValue)
        external
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            upgradedToken.decreaseAllowanceProxy(sender, spender, subtractedValue);
        } else {
            decreaseAllowanceGuarded(sender, spender, subtractedValue);
        }
    }

    function pausedProxy(address sender)
        external
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            upgradedToken.pausedProxy(sender);
        } else {
            pausedGuarded(sender);
        }
    }
}
