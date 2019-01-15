pragma solidity ^0.4.24;

import "../token/ETokenizeExplicitSender.sol";

/**
 * @title Mock contract for testing eTokenizeExplicitSender
 */
contract ETokenizeExplicitSenderMock is ETokenizeExplicitSender {

    /**
     * Initializes an eTokenizeExplicitSender. Forwards parameters
     * as is except that the initial minting recipient (see
     * tokens/ERC20/ExternalERC20Mintable) is set to a static value.
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        ExternalERC20Storage stor,
        IUpgradableETokenize upgradedFrom,
        bool initialDeployment
    )
        public
        ETokenizeExplicitSender(
            name, symbol, decimals, accesslist, whitelistEnabled,
            stor, address(0xf00f), upgradedFrom, initialDeployment)
    {}
}
