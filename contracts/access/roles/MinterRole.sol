pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract MinterRole is Ownable {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private minters;

    constructor() internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "not minter");
        _;
    }

    modifier requireMinter(address account) {
        require(isMinter(account), "not minter");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return minters.has(account);
    }

    function addMinter(address account) public onlyOwner {
        _addMinter(account);
    }

    function removeMinter(address account) public onlyOwner {
        _removeMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        minters.remove(account);
        emit MinterRemoved(account);
    }
}
