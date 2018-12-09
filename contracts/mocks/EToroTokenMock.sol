pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Storage.sol";
import "../token/EToroToken.sol";

contract EToroTokenMock is EToroToken {

    constructor(string name,
                string symbol,
                uint8 decimals,
                address whitelistAddress)
        EToroToken(name, symbol, decimals,
                   msg.sender, whitelistAddress, new ExternalERC20Storage())
        public { }
}
