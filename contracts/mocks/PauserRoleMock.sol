pragma solidity ^0.4.24;

import "../roles/PauserRole.sol";

contract PauserRoleMock is PauserRole {

  function onlyPauserMock() public view onlyPauser {
  }

  function requirePauserMock(address a) public view requirePauser(a) {
  }

  // Causes compilation errors if functions are not declared internal
  function _removePauser(address account) internal {
    super._removePauser(account);
  }

  function _addPauser(address account) internal {
    super._addPauser(account);
  }
}
