pragma solidity ^0.4.24;

import "./Accesslist.sol";

/**
 *  @title The AccesslistGuarded contract
 *  @dev Contract containing an accesslist and
 *       modifiers to ensure proper access
 */
contract AccesslistGuarded {

    Accesslist private accesslist;
    bool public whitelistEnabled;

    constructor(
        Accesslist _accesslist,
        bool _whitelistEnabled
    )
        public
    {
        require(
            _accesslist != Accesslist(0),
            "Supplied accesslist is null"
        );
        accesslist = _accesslist;
        whitelistEnabled = _whitelistEnabled;
    }

    /**
     *  @dev Modifier that requires given address
     *       to be whitelisted and not blacklisted
     *  @param account address to be checked
     */
    modifier requireHasAccess(address account) {
        require(
            hasAccess(account),
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
            hasAccess(msg.sender),
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
            isWhitelisted(account),
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
            isWhitelisted(msg.sender),
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
            isNotBlacklisted(account),
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
            isNotBlacklisted(msg.sender),
            "Sender address is blacklisted"
        );
        _;
    }

    /**
     *  @dev Returns whether account has access.
     *       If whitelist is enabled a whitelist check is also made,
     *       otherwise it only checks for blacklisting.
     *  @param account address to be checked
     */
    function hasAccess(address account) public view returns (bool) {
        if (whitelistEnabled) {
            return accesslist.hasAccess(account);
        } else {
            return isNotBlacklisted(account);
        }
    }

    /**
     *  @dev Returns whether account is whitelisted
     *  @param account address to be checked
     */
    function isWhitelisted(address account) public view returns (bool) {
        return accesslist.isWhitelisted(account);
    }

    /**
     *  @dev Returns whether account is not blacklisted
     *  @param account address to be checked
     */
    function isNotBlacklisted(address account) public view returns (bool) {
        return !accesslist.isBlacklisted(account);
    }
}
