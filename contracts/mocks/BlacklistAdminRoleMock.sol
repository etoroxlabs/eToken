pragma solidity ^0.4.24;

import "../access/roles/BlacklistAdminRole.sol";

/**
 *  @title An Blacklist admin mock contract
 *  @dev Contract to test currently unused modifiers and functions for
 *  the blacklist administrator role
 */
contract BlacklistAdminRoleMock is BlacklistAdminRole {

    /** @dev Tests the msg.sender-dependent onlyBlacklistAdmin modifier */
    function onlyBlacklistAdminMock() public view onlyBlacklistAdmin {
    }

    /** @dev Tests the requireBlacklistAdmin modifier which checks if the
     * given address is a blacklist admin
     * @param a Address to be checked
     */
    function requireBlacklistAdminMock(address a)
        public
        view
        requireBlacklistAdmin(a)
    {
    }

    /** @dev Causes compilation errors if _removeBlacklistAdmin function is not declared internal */
    function _removeBlacklistAdmin(address account) internal {
        super._removeBlacklistAdmin(account);
    }

    /** @dev Causes compilation errors if _removeBlacklistAdmin function is not declared internal */
    function _addBlacklistAdmin(address account) internal {
        super._addBlacklistAdmin(account);
    }
}
