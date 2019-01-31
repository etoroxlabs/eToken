pragma solidity 0.4.24;

import "../token/access/roles/BurnerRole.sol";

/**
 * @title Burner role mock contract
 * @dev Contract to test currently unused modifiers and functions for
 * the burner role
 */
contract BurnerRoleMock is BurnerRole {

    /** @dev Tests the msg.sender-dependent onlyBurner modifier */
    function onlyBurnerMock() public view onlyBurner {
    }

    /** @dev Tests the requireBurner modifier which checks if the
     * given address is a blacklist admin
     * @param a The address to be checked
     */
    function requireBurnerMock(address a) public view requireBurner(a) {
    }

    /** @dev Causes compilation errors if _removeBurner function is not declared internal */
    function _removeBurner(address account) internal {
        super._removeBurner(account);
    }

    /** @dev Causes compilation errors if _removeBurner function is not declared internal */
    function _addBurner(address account) internal {
        super._addBurner(account);
    }
}
