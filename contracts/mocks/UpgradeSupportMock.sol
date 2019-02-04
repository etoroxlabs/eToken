pragma solidity 0.4.24;

import "../token/access/Accesslist.sol";
import "../token/access/ETokenGuarded.sol";
import "../token/ERC20/Storage.sol";

/**
 * @title Mock contract for testing UpgradeSupport
 */
contract ETokenGuardedMock is ETokenGuarded {

    constructor(
        Storage initialStorage,
        address upgradedFrom,
        bool initialDeployment
    )
        public
        ETokenGuarded("test", "te", 4, Accesslist(0xf00), true,
                      initialStorage, address(0xf00), initialDeployment)
        UpgradeSupport(initialDeployment, upgradedFrom)
        {}
}
