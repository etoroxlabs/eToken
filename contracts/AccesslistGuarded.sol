pragma solidity ^0.4.24;

import "./Accesslist.sol";

contract AccesslistGuarded {

    Accesslist private accesslist;

    constructor(Accesslist _accesslist) public {
        require(_accesslist != Accesslist(0));
        accesslist = _accesslist;
    }

    modifier requireHasAccess(address account) {
        require(accesslist.hasAccess(account));
        _;
    }

    modifier onlyHasAccess() {
        require(accesslist.hasAccess(msg.sender));
        _;
    }

    modifier requireWhitelisted(address account) {
        require(accesslist.isWhitelisted(account));
        _;
    }

    modifier onlyWhitelisted() {
        require(accesslist.isWhitelisted(msg.sender));
        _;
    }

    modifier requireNotBlacklisted(address account) {
        require(!accesslist.isBlacklisted(account));
        _;
    }

    modifier onlyNotBlacklisted() {
        require(!accesslist.isBlacklisted(msg.sender));
        _;
    }
}
