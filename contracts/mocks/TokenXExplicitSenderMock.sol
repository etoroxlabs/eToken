pragma solidity ^0.4.24;

import "../token/TokenXExplicitSender.sol";

contract TokenXExplicitSenderMock is TokenXExplicitSender {

    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        ExternalERC20Storage stor,
        IUpgradableTokenX upgradedFrom,
        bool initialDeployment
    )
        public
        TokenXExplicitSender(
            name, symbol, decimals, accesslist, whitelistEnabled,
            stor, address(0xf00f), upgradedFrom, initialDeployment)
    {}
}
