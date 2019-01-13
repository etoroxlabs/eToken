pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/** @title Contract managing the blacklist admin role */
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

    /**
     * @dev Checks if account is blacklist admin
     * @param account Account to check
     * @return Boolean indicating if account is blacklist admin
     */
    function isBlacklistAdmin(address account) public view returns (bool) {
        return blacklistAdmins.has(account);
    }

    /**
     * @dev Adds a blacklist admin account. Is only callable by owner.
     * @param account Address to be added
     */
    function addBlacklistAdmin(address account) public onlyOwner {
        _addBlacklistAdmin(account);
    }

    /**
     * @dev Removes a blacklist admin account. Is only callable by owner
     * @param account Address to be removed
     */
    function removeBlacklistAdmin(address account) public onlyOwner {
        _removeBlacklistAdmin(account);
    }

    /** @dev Allows privilege holder to renounce their role */
    function renounceBlacklistAdmin() public {
        _removeBlacklistAdmin(msg.sender);
    }

    /** @dev Internal implementation of addBlacklistAdmin */
    function _addBlacklistAdmin(address account) internal {
        blacklistAdmins.add(account);
        emit BlacklistAdminAdded(account);
    }

    /** @dev Internal implementation of removeBlacklistAdmin */
    function _removeBlacklistAdmin(address account) internal {
        blacklistAdmins.remove(account);
        emit BlacklistAdminRemoved(account);
    }
}
