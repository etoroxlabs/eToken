pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract KillSwitch is Ownable {
    bool private isOn = false;

    modifier killSwitchOff() {
        checkKillSwitch(msg.sender);
        _;
    }

    function checkKillSwitch(address user) public view returns (bool) {
        if (user != owner) {
            return !isOn;
        }
    }
/*
    function freezeAccount(address user) public onlyOwner {

    }
*/

    function enableKillSwitch(bool value) public onlyOwner {
        isOn = value;
    }
}