pragma solidity ^0.4.24;

import "./Accesslist.sol";

/**
 *  @title The AccesslistGuarded contract
 *  @dev Contract containing an accesslist and
 *       modifiers to ensure proper access
 */
contract AccesslistGuarded {

    Accesslist private accesslist;

    constructor(Accesslist _accesslist) public {
        require(_accesslist != Accesslist(0), "Supplied accesslist is null");
        accesslist = _accesslist;
    }

    /**
     *  @dev Modifier that requires given address
     *       to be whitelisted and not blacklisted
     *  @param account address to be checked
     */
    modifier requireHasAccess(address account) {
        require(
            accesslist.hasAccess(account),
            "Supplied address doesn't have access"
        );
        _;
    }

    /**
     *  @dev Modifier that requires the message sender
     *       to be whitelisted and not blacklisted
     */
    modifier onlyHasAccess() {
        require(
            accesslist.hasAccess(msg.sender),
            "Sender address doesn't have access"
        );
        _;
    }

    /**
     *  @dev Modifier that requires given address
     *       to be whitelisted
     *  @param account address to be checked
     */
    modifier requireWhitelisted(address account) {
        require(
            accesslist.isWhitelisted(account),
            "Supplied address is not whitelisted"
        );
        _;
    }

    /**
     *  @dev Modifier that requires message sender
     *       to be whitelisted
     */
    modifier onlyWhitelisted() {
        require(
            accesslist.isWhitelisted(msg.sender),
            "Sender address is not whitelisted"
        );
        _;
    }

    /**
     *  @dev Modifier that requires given address
     *       to not be blacklisted
     *  @param account address to be checked
     */
    modifier requireNotBlacklisted(address account) {
        require(
            !accesslist.isBlacklisted(account),
            "Supplied address is blacklisted"
        );
        _;
    }

    /**
     *  @dev Modifier that requires message sender
     *       to not be blacklisted
     */
    modifier onlyNotBlacklisted() {
        require(
            !accesslist.isBlacklisted(msg.sender),
            "Sender address is blacklisted"
        );
        _;
    }
}
