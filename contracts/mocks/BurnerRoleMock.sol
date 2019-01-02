pragma solidity ^0.4.24;

import "../access/roles/BurnerRole.sol";

contract BurnerRoleMock is BurnerRole {

    function onlyBurnerMock() public view onlyBurner {
    }

    function requireBurnerMock(address a) public view requireBurner(a) {
    }

    // Causes compilation errors if functions are not declared internal
    function _removeBurner(address account) internal {
        super._removeBurner(account);
    }

    function _addBurner(address account) internal {
        super._addBurner(account);
    }
}
