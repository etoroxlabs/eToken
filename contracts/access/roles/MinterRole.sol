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
     * @dev checks if the message sender is a minter
     */
    modifier onlyMinter() {
        require(isMinter(msg.sender), "not minter");
        _;
    }

    /**
     * @dev checks if the given address is a minter
     * @param account address to be checked
     */
    modifier requireMinter(address account) {
        require(isMinter(account), "not minter");
        _;
    }

    /**
     * @dev Checks if given address is a minter
     * @param account address to be checked
     * @return is the address a minter
     */
    function isMinter(address account) public view returns (bool) {
        return minters.has(account);
    }

    /**
     * @dev calls internal function _addMinter with given address
     * can only be called by owner
     * @param account address to be passed
     */
    function addMinter(address account) public onlyOwner {
        _addMinter(account);
    }

    /**
     * @dev calls internal function _removeMinter with given address
     * can only be called by owner
     * @param account address to be passed
     */
    function removeMinter(address account) public onlyOwner {
        _removeMinter(account);
    }

    /**
     * @dev calls internal function _removeMinter with message sender
     * as the parameter
     */
    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    /**
     * @dev adds given address to minters
     * @param account address to be added
     */
    function _addMinter(address account) internal {
        minters.add(account);
        emit MinterAdded(account);
    }

    /**
     * @dev removes given address from minters
     * @dev address to be removed.
     */
    function _removeMinter(address account) internal {
        minters.remove(account);
        emit MinterRemoved(account);
    }
}
