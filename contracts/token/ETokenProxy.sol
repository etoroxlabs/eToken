pragma solidity 0.4.24;

import "./IETokenProxy.sol";

contract ETokenProxy is IETokenProxy {

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
            upgradedToken.balanceOfProxy(sender);
        } else {
            balanceOfGuarded(sender);
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
            upgradedToken.allowanceProxyProxy(sender);
        } else {
            allowanceProxyGuarded(sender);
        }
    }


    function transferProxy(address sender, address to, uint256 value)
        external
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            upgradedToken.transferProxy(sender);
        } else {
            transferGuarded(sender);
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
            upgradedToken.approveProxy(sender);
        } else {
            approveGuarded(sender);
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
            upgradedToken.transferFromProxy(sender);
        } else {
            transferFromGuarded(sender);
        }
    }

    function mintProxy(address sender, address to, uint256 value)
        external
        onlyProxy
        returns (bool)
    {
        if (isUpgraded()) {
            upgradedToken.fooProxy(sender);
        } else {
            fooGuarded(sender);
        }
    }

    function changeMintingRecipientProxy(address sender,
                                         address mintingRecip)
        external
        onlyProxy
    {
        if (isUpgraded()) {
            upgradedToken.changeMintingRecipientProxy(sender);
        } else {
            changeMintingRecipientGuarded(sender);
        }
    }

    function burnProxy(address sender, uint256 value) external {
        if (isUpgraded()) {
            upgradedToken.burnProxy(sender);
        } else {
            burnGuarded(sender);
        }
    }

    function burnFromProxy(address sender,
                           address from,
                           uint256 value)
        external
        onlyProxy
    {
        if (isUpgraded()) {
            upgradedToken.burnFromProxy(sender);
        } else {
            burnFromGuarded(sender);
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
            upgradedToken.increaseAllowanceProxy(sender);
        } else {
            increaseAllowanceGuarded(sender);
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
            upgradedToken.decreaseAllowanceProxy(sender);
        } else {
            decreaseAllowanceGuarded(sender);
        }
    }

}
