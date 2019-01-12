pragma solidity ^0.4.24;

import "../access/roles/BurnerRole.sol";

/**
 * @title Burner role mock contract
 * @dev Contract to test currently unused modifiers and functions for
 * the burner role
 */

contract BurnerRoleMock is BurnerRole {

    /**
     * @dev returns true if message sender is a burner
     */
    function onlyBurnerMock() public view onlyBurner {
    }

    /**
     * @dev returns true if given address is a burner
     * @param a the address to be given
     */
    function requireBurnerMock(address a) public view requireBurner(a) {
    }

    /**
     * @dev removes given address from burners
     * @param address to be removed
     */
    function _removeBurner(address account) internal {
        super._removeBurner(account);
    }

    /**
     * @dev adds given address to burners
     * @param account address to be added
     */
    function _addBurner(address account) internal {
        super._addBurner(account);
    }
}
