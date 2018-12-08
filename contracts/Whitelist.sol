pragma solidity 0.4.24;

import "etokenize-openzeppelin-solidity/contracts/access/Roles.sol";
import "etokenize-openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol";


contract Whitelist is WhitelistAdminRole {


    using Roles for Roles.Role;

    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);

    Roles.Role private whitelist;

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

    function isWhitelisted(address account)
        public
        view
        returns (bool)
    {
        return whitelist.has(account) || isWhitelistAdmin(account);
    }

    function _addWhitelisted(address account) internal {
        whitelist.add(account);
        emit WhitelistAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        whitelist.remove(account);
        emit WhitelistRemoved(account);
    }
}
