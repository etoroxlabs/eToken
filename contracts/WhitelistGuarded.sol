pragma solidity ^0.4.24;

import "./Whitelist.sol";

contract WhitelistGuarded {

    modifier requireWhitelisted(Whitelist wl, address account) {
        require(wl.isWhitelisted(account));
        _;
    }

    modifier onlyWhitelisted(Whitelist wl) {
        require(wl.isWhitelisted(msg.sender));
        _;
    }

}
