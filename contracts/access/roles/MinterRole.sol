pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/** @title The minter role contract */
contract MinterRole is Ownable {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private minters;

    /**
     * @dev Checks if the message sender is a minter
     */
    modifier onlyMinter() {
        require(isMinter(msg.sender), "not minter");
        _;
    }

    /**
     * @dev Checks if the given address is a minter
     * @param account Address to be checked
     */
    modifier requireMinter(address account) {
        require(isMinter(account), "not minter");
        _;
    }

    /**
     * @dev Checks if given address is a minter
     * @param account Address to be checked
     * @return Is the address a minter
     */
    function isMinter(address account) public view returns (bool) {
        return minters.has(account);
    }

    /**
     * @dev Calls internal function _addMinter with the given address.
     * Can only be called by the owner.
     * @param account Address to be passed
     */
    function addMinter(address account) public onlyOwner {
        _addMinter(account);
    }

    /**
     * @dev Calls internal function _removeMinter with the given address.
     * Can only be called by the owner.
     * @param account Address to be passed
     */
    function removeMinter(address account) public onlyOwner {
        _removeMinter(account);
    }

    /**
     * @dev Calls internal function _removeMinter with message sender
     * as the parameter
     */
    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    /**
     * @dev Adds the given address to minters
     * @param account Address to be added
     */
    function _addMinter(address account) internal {
        minters.add(account);
        emit MinterAdded(account);
    }

    /**
     * @dev Removes given address from minters
     * @param account Address to be removed.
     */
    function _removeMinter(address account) internal {
        minters.remove(account);
        emit MinterRemoved(account);
    }
}
