pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./KillSwitch.sol";

contract NameRegistry is KillSwitch, Ownable {

    mapping(string => address) _registry;

    function _nameExists(string name)
      private
      view
      returns (bool) {
      _registry[name] == address(0);
    }

    modifier nameExists(string name) {
      require (_nameExists(name), "Name already exists");
      _;
    }

    modifier nameNotExists(string name) {
      require (!(_nameExists(name)), "Name does not exists");
      _;
    }

    function lookupName(string name)
      public nameExists
      view
      returns (address){
        return _registry[name];
    }

    function createName(string name, address dest)
      public onlyOwner nameNotExists {
        _registry[name] = dest;
    }

    function modifyName(string oldName, string newName, address dest)
      public onlyOwner nameExists {
      _registry[name] = dest;
    }

    function deleteName(string name)
      public onlyOwner nameExists {
        delete _registry[name];
    }
}
