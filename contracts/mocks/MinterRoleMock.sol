pragma solidity ^0.4.24;

import "../access/roles/MinterRole.sol";

/**
 * @title Mock contract for testing MinterRole
 */
contract MinterRoleMock is MinterRole {

    /** Tests the msg.sender-dependent onlyMinter modifier */
    function onlyMinterMock() public view onlyMinter {
    }

    /** Tests the requireMinter modifier which checks if the
      * given address is a minter
      * @param a The address to be checked
     */
    function requireMinterMock(address a) public view requireMinter(a) {
    }

    /** Causes compilation errors if _removeMinter function is not declared internal */
    function _removeMinter(address account) internal {
        super._removeMinter(account);
    }

    /** Causes compilation errors if _removeMinter function is not declared internal */
    function _addMinter(address account) internal {
        super._addMinter(account);
    }
}
