pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract WhitelistedRole is Ownable {
  using Roles for Roles.Role;

  event WhitelistedAdded(address indexed account);
  event WhitelistedRemoved(address indexed account);

  Roles.Role private whitelisted;

  /* constructor() internal { */
  /*   _addWhitelisted(msg.sender); */
  /* } */

  modifier onlyWhitelisted() {
    require(isWhitelisted(msg.sender));
    _;
  }

  function isWhitelisted(address account) public view returns (bool) {
    return whitelisted.has(account);
  }

  function addWhitelisted(address account) public onlyOwner {
    _addWhitelisted(account);
  }

  function removeWhitelisted(address account) public onlyOwner {
    _removeWhitelisted(account);
  }

  function renounceWhitelisted() public {
    _removeWhitelisted(msg.sender);
  }

  function _addWhitelisted(address account) internal {
    whitelisted.add(account);
    emit WhitelistedAdded(account);
  }

  function _removeWhitelisted(address account) internal {
    whitelisted.remove(account);
    emit WhitelistedRemoved(account);
  }
}
