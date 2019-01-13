pragma solidity ^0.4.24;

import "../access/AccesslistGuarded.sol";

/**
 * @title An AccesslistGuarded mock contract
 * @dev Contracts to test currently unused modifiers in AccesslistGuarded
 */
contract AccesslistGuardedMock is AccesslistGuarded {

    constructor(Accesslist _accesslist, bool whitelistEnabled)
        AccesslistGuarded(_accesslist, whitelistEnabled)
        public
    {
    }

    /**
     * @dev Function that returns true if
     * given address has access
     * @param account Address to check
     */
    function requireHasAccessMock(address account)
        public
        view
        requireHasAccess(account)
        returns (bool)
    {
        return true;
    }

    /**
     * @dev Function that returns true if
     * message sender has access
     */
    function onlyHasAccessMock()
        public
        view
        onlyHasAccess
        returns (bool)
    {
        return true;
    }

    /**
     * @dev Function that returns true if
     * given address is whitelisted
     * @param account Address to check
     */
    function requireWhitelistedMock(address account)
        public
        view
        requireWhitelisted(account)
        returns (bool)
    {
        return true;
    }

    /**
     * @dev Function that returns true if
     * message sender is Whitelisted
     */
    function onlyWhitelistedMock()
        public
        view
        onlyWhitelisted
        returns (bool)
    {
        return true;
    }

    /**
     * @dev Function that returns true if
     * given address isn't blacklisted
     * @param account Address to check
     */
    function requireNotBlacklistedMock(address account)
        public
        view
        requireNotBlacklisted(account)
        returns (bool)
    {
        return true;
    }

    /**
     * @dev Function that returns true if
     * message sender isn't blacklisted
     */
    function onlyNotBlacklistedMock()
        public
        view
        onlyNotBlacklisted
        returns (bool)
    {
        return true;
    }
}
