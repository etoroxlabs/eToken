pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract AdministratorRole is Ownable {
  using Roles for Roles.Role;

  event AdminAdded(address indexed account);
  event AdminRemoved(address indexed account);

  Roles.Role private admin;

  /**
  /*  contructor() internal {
  /*      _addAdmin(msg.sender);
  /*  }
   */

  modifier onlyAdmin() {
      require(isAdmin(msg.sender));
      _;
  }

  function isAdmin(address account) public view returns (bool) {
      return admin.has(account);
  }

  function addAdmin(address account) public onlyOwner {
      _addAdmin(account);
  }

  function removeAdmin(address account) public onlyOwner {
      _removeAdmin(account);
  }

  function renounceAdmin() public {
      _removeAdmin(msg.sender);
  }

  function _addAdmin(address account) internal {
      admin.add(account);
      emit AdminAdded(account);
  }

  function _removeAdmin(address account) internal {
      admin.remove(account);
      emit AdminRemoved(account);
  }
}