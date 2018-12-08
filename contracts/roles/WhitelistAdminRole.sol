pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/Roles.sol";

contract WhitelistAdminRole {
  using Roles for Roles.Role;

  event WhitelistAdminAdded(address indexed account);
  event WhitelistAdminRemoved(address indexed account);

  Roles.Role private whitelistAdmins;

  constructor() internal {
    _addWhitelistAdmin(msg.sender);
  }

  modifier onlyWhitelistAdmin() {
    require(isWhitelistAdmin(msg.sender));
    _;
  }

  function isWhitelistAdmin(address account) public view returns (bool) {
    return whitelistAdmins.has(account);
  }

  function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
    _addWhitelistAdmin(account);
  }

    function renounceWhitelistAdmin() public {
    _removeWhitelistAdmin(msg.sender);
  }

  function _addWhitelistAdmin(address account) internal {
    whitelistAdmins.add(account);
    emit WhitelistAdminAdded(account);
  }

  function _removeWhitelistAdmin(address account) internal {
    whitelistAdmins.remove(account);
    emit WhitelistAdminRemoved(account);
  }
}
