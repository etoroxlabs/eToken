pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "./roles/WhitelistAdminRole.sol";
import "./roles/BlacklistAdminRole.sol";

/**
 * @title The Accesslist contract
 * @dev Contract that contains a whitelist and a blacklist and manages them
 */
contract Accesslist is WhitelistAdminRole, BlacklistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);
    event BlacklistAdded(address indexed account);
    event BlacklistRemoved(address indexed account);

    Roles.Role private whitelist;
    Roles.Role private blacklist;

    /**
     * @dev Calls internal function _addWhitelisted
     * to add given address to whitelist
     * @param account Address to be added
     */
    function addWhitelisted(address account)
        public
        onlyWhitelistAdmin
    {
        _addWhitelisted(account);
    }

    /**
     * @dev Calls internal function _removeWhitelisted
     * to remove given address from the whitelist
     * @param account Address to be removed
     */
    function removeWhitelisted(address account)
        public
        onlyWhitelistAdmin
    {
        _removeWhitelisted(account);
    }

    /**
     * @dev Calls internal function _addBlacklisted
     * to add given address to blacklist
     * @param account Address to be added
     */
    function addBlacklisted(address account)
        public
        onlyBlacklistAdmin
    {
        _addBlacklisted(account);
    }

    /**
     * @dev Calls internal function _removeBlacklisted
     * to remove given address from blacklist
     * @param account Address to be removed
     */
    function removeBlacklisted(address account)
        public
        onlyBlacklistAdmin
    {
        _removeBlacklisted(account);
    }

    /**
     * @dev Checks to see if the given address is whitelisted
     * @param account Address to be checked
     * @return true if address is whitelisted
     */
    function isWhitelisted(address account)
        public
        view
        returns (bool)
    {
        return whitelist.has(account);
    }

    /**
     * @dev Checks to see if given address is blacklisted
     * @param account Address to be checked
     * @return true if address is blacklisted
     */
    function isBlacklisted(address account)
        public
        view
        returns (bool)
    {
        return blacklist.has(account);
    }

    /**
     * @dev Checks to see if given address is whitelisted and not blacklisted
     * @param account Address to be checked
     * @return true if address has access
     */
    function hasAccess(address account)
        public
        view
        returns (bool)
    {
        return isWhitelisted(account) && !isBlacklisted(account);
    }


    /**
     * @dev Adds given address to the whitelist
     * @param account Address to be added
     */
    function _addWhitelisted(address account) internal {
        whitelist.add(account);
        emit WhitelistAdded(account);
    }

    /**
     * @dev Removes given address to the whitelist
     * @param account Address to be removed
     */
    function _removeWhitelisted(address account) internal {
        whitelist.remove(account);
        emit WhitelistRemoved(account);
    }

    /**
     * @dev Adds given address to the blacklist
     * @param account Address to be added
     */
    function _addBlacklisted(address account) internal {
        blacklist.add(account);
        emit BlacklistAdded(account);
    }

    /**
     * @dev Removes given address to the blacklist
     * @param account Address to be removed
     */
    function _removeBlacklisted(address account) internal {
        blacklist.remove(account);
        emit BlacklistRemoved(account);
    }
}
