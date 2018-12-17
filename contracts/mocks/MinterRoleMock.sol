pragma solidity ^0.4.24;

import "../roles/MinterRole.sol";

contract MinterRoleMock is MinterRole {

  function onlyMinterMock() public view onlyMinter {
  }

  function requireMinterMock(address a) public view requireMinter(a) {
  }

  // Causes compilation errors if functions are not declared internal
  function _removeMinter(address account) internal {
    super._removeMinter(account);
  }

  function _addMinter(address account) internal {
    super._addMinter(account);
  }
}
