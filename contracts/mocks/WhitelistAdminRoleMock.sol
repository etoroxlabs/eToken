pragma solidity ^0.4.24;

import "../roles/WhitelistAdminRole.sol";

contract WhitelistAdminRoleMock is WhitelistAdminRole {

  function onlyWhitelistAdminMock() public view onlyWhitelistAdmin {
  }

  function requireWhitelistAdminMock(address a)
    public
    view
    requireWhitelistAdmin(a) {}

  // Causes compilation errors if functions are not declared internal
  function _removeWhitelistAdmin(address account) internal {
    super._removeWhitelistAdmin(account);
  }

  function _addWhitelistAdmin(address account) internal {
    super._addWhitelistAdmin(account);
  }
}
