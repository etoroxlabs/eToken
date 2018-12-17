pragma solidity ^0.4.24;

/* solium-disable max-len */
import "../token/ERC20/ExternalERC20Storage.sol";
import "../token/EToroToken.sol";
/* solium-enable max-len */

contract EToroTokenMock is EToroToken {

    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist
    )
        EToroToken(
            name, symbol, decimals,
            accesslist, new ExternalERC20Storage()
        )
        public
    {
    }
}
