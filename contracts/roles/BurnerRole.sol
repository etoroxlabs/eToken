pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract BurnerRole is Ownable {
  using Roles for Roles.Role;

  event BurnerAdded(address indexed account);
  event BurnerRemoved(address indexed account);

  Roles.Role private burners;

  constructor() Ownable() internal {
    _addBurner(msg.sender);
  }

  modifier onlyBurner() {
    require(isBurner(msg.sender));
    _;
  }

  modifier requireBurner(address account) {
    require(isBurner(account));
    _;
  }

  function isBurner(address account) public view returns (bool) {
    return burners.has(account);
  }

  function addBurner(address account) public onlyOwner {
    _addBurner(account);
  }

  function removeBurner(address account) public onlyOwner {
    _removeBurner(account);
  }

  function renounceBurner() public {
    _removeBurner(msg.sender);
  }

  function _addBurner(address account) internal {
    burners.add(account);
    emit BurnerAdded(account);
  }

  function _removeBurner(address account) internal {
    burners.remove(account);
    emit BurnerRemoved(account);
  }
}
