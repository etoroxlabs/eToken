pragma solidity ^0.4.24;

import "../access/roles/BlacklistAdminRole.sol";

/**
 *  @title An Blacklist admin mock contract
 *  @dev Contract to test currently unused modifiers and functions for
 *  the blacklist administrator role
 */

contract BlacklistAdminRoleMock is BlacklistAdminRole {

    function onlyBlacklistAdminMock() public view onlyBlacklistAdmin {
    }

    /**
     * @dev returns true if given address is blacklist administrator
     */
    function requireBlacklistAdminMock(address a)
        public
        view
        requireBlacklistAdmin(a)
    {
    }

    /**
     * @dev removes given address from blacklist administrators
     * @param account address to be removed
     */
    function _removeBlacklistAdmin(address account) internal {
        super._removeBlacklistAdmin(account);
    }

    /**
     * @dev adds given address to blacklist administrators
     * @param account address to be added
     */
    function _addBlacklistAdmin(address account) internal {
        super._addBlacklistAdmin(account);
    }
}
