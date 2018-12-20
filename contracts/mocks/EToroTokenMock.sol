pragma solidity ^0.4.24;

import "../token/ERC20/ExternalERC20Storage.sol";
import "../token/EToroToken.sol";

contract EToroTokenMock is EToroToken {

    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled
    )
        EToroToken(
            name, symbol, decimals,
            accesslist, whitelistEnabled,
            new ExternalERC20Storage()
        )
        public
    {
    }
}
