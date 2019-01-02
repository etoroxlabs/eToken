pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract BlacklistAdminRole is Ownable {
    using Roles for Roles.Role;

    event BlacklistAdminAdded(address indexed account);
    event BlacklistAdminRemoved(address indexed account);

    Roles.Role private blacklistAdmins;

    constructor() internal {
        _addBlacklistAdmin(msg.sender);
    }

    modifier onlyBlacklistAdmin() {
        require(isBlacklistAdmin(msg.sender), "not blacklistAdmin");
        _;
    }

    modifier requireBlacklistAdmin(address account) {
        require(isBlacklistAdmin(account), "not blacklistAdmin");
        _;
    }

    function isBlacklistAdmin(address account) public view returns (bool) {
        return blacklistAdmins.has(account);
    }

    function addBlacklistAdmin(address account) public onlyOwner {
        _addBlacklistAdmin(account);
    }

    function removeBlacklistAdmin(address account) public onlyOwner {
        _removeBlacklistAdmin(account);
    }

    function renounceBlacklistAdmin() public {
        _removeBlacklistAdmin(msg.sender);
    }

    function _addBlacklistAdmin(address account) internal {
        blacklistAdmins.add(account);
        emit BlacklistAdminAdded(account);
    }

    function _removeBlacklistAdmin(address account) internal {
        blacklistAdmins.remove(account);
        emit BlacklistAdminRemoved(account);
    }
}
