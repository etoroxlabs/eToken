pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "./roles/WhitelistAdminRole.sol";
import "./roles/BlacklistAdminRole.sol";

contract Accesslist is WhitelistAdminRole, BlacklistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);
    event BlacklistAdded(address indexed account);
    event BlacklistRemoved(address indexed account);

    Roles.Role private whitelist;
    Roles.Role private blacklist;

    function addWhitelisted(address account)
        public
        onlyWhitelistAdmin
    {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account)
        public
        onlyWhitelistAdmin
    {
        _removeWhitelisted(account);
    }

    function addBlacklisted(address account)
        public
        onlyBlacklistAdmin
    {
        _addBlacklisted(account);
    }

    function removeBlacklisted(address account)
        public
        onlyBlacklistAdmin
    {
        _removeBlacklisted(account);
    }

    function isWhitelisted(address account)
        public
        view
        returns (bool)
    {
        return whitelist.has(account);
    }

    function isBlacklisted(address account)
        public
        view
        returns (bool)
    {
        return blacklist.has(account);
    }

    function hasAccess(address account)
        public
        view
        returns (bool)
    {
        return isWhitelisted(account) && !isBlacklisted(account);
    }

    function _addWhitelisted(address account) internal {
        whitelist.add(account);
        emit WhitelistAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        whitelist.remove(account);
        emit WhitelistRemoved(account);
    }

    function _addBlacklisted(address account) internal {
        blacklist.add(account);
        emit BlacklistAdded(account);
    }

    function _removeBlacklisted(address account) internal {
        blacklist.remove(account);
        emit BlacklistRemoved(account);
    }
}
