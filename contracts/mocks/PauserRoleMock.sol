pragma solidity ^0.4.24;

import "../access/roles/PauserRole.sol";

/**
 * @title Mock contract for testing PauserRole
 */
contract PauserRoleMock is PauserRole {

    /** Tests the msg.sender-dependent onlyPauser modifier */
    function onlyPauserMock() public view onlyPauser {
    }

    /** Tests the requirePauser modifier which checks if the
      * given address is a pauser
      * @param a The address to be checked
      */
    function requirePauserMock(address a) public view requirePauser(a) {
    }

    /** Causes compilation errors if _removePauser function is not declared internal */
    function _removePauser(address account) internal {
        super._removePauser(account);
    }

    /** Causes compilation errors if _removePauser function is not declared internal */
    function _addPauser(address account) internal {
        super._addPauser(account);
    }
}
