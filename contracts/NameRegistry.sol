pragma solidity ^0.4.24;

import "./EToroRole.sol";
import "./KillSwitch.sol";

contract NameRegistry is KillSwitch, EToroRole{

    mapping(string => address) _registry;

    function lookupName(string name) public view returns (address){
        require(
            _registry[name] != address(0), 
            "Name does not exist."
        );
        return _registry[name];
    }

    function createName(string name, address user) public onlyOwner {
        require(
            _registry[name] == address(0),
            "Name already exists"
        );
        _registry[name] = user;
    }

    function deleteName(string name) public onlyOwner {
        require(
            _registry[name] != address(0), 
            "Name does not exist."
        );
        _registry[name] = address(0);
    }
}