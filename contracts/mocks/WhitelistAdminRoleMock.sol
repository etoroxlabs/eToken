pragma solidity ^0.4.24;

import "../access/roles/WhitelistAdminRole.sol";

/** @title Mock contract for testing WhitelistAdminRole */
contract WhitelistAdminRoleMock is WhitelistAdminRole {

    /** Tests the msg.sender-dependent onlyWhitelistAdmin modifier */
    function onlyWhitelistAdminMock() public view onlyWhitelistAdmin {
    }

    /** Tests the requireWhitelistAdmin modifier which checks if the
      * given address is whitelsited
      * @param a The address to be checked
      */
    function requireWhitelistAdminMock(address a)
        public
        view
        requireWhitelistAdmin(a)
    {
    }

    /** Causes compilation errors if _removeWhitelistAdmin function is not declared internal */
    function _removeWhitelistAdmin(address account) internal {
        super._removeWhitelistAdmin(account);
    }

    /** Causes compilation errors if _removeWhitelistAdmin function is not declared internal */
    function addWhitelistAdmin(address account) internal {
        super._addWhitelistAdmin(account);
    }
}
