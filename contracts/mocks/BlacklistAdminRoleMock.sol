pragma solidity ^0.4.24;

import "../roles/BlacklistAdminRole.sol";

contract BlacklistAdminRoleMock is BlacklistAdminRole {

    function onlyBlacklistAdminMock() public view onlyBlacklistAdmin {
    }

    function requireBlacklistAdminMock(address a)
        public
        view
        requireBlacklistAdmin(a)
    {
    }

    // Causes compilation errors if functions are not declared internal
    function _removeBlacklistAdmin(address account) internal {
        super._removeBlacklistAdmin(account);
    }

    function _addBlacklistAdmin(address account) internal {
        super._addBlacklistAdmin(account);
    }
}
