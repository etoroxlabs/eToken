pragma solidity ^0.4.24;

import "./EToroToken.sol";
import "./KillSwitch.sol";
import "./NameRegistry.sol";

contract TokenManager is KillSwitch, NameRegistry, EToroToken{
    
    NameRegistry private nameRegistry;
    EToroToken private eToroToken;

/*
    function createToken(address user) {

    }

    function getTokens() {

    }

    function destroyToken() {

    }
*/
}