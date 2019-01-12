pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/** @title Contract managing the pauser role */
contract PauserRole is Ownable {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private pausers;

    constructor() internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "not pauser");
        _;
    }

    modifier requirePauser(address account) {
        require(isPauser(account), "not pauser");
        _;
    }

    /** Checks if account is pauser
     * @param account Account to check
     * @return Boolean indicating if account is pauser
     */
    function isPauser(address account) public view returns (bool) {
        return pausers.has(account);
    }

    /** Adds a pauser account
     * @dev Is only callable by owner
     * @param account to be added
     */
    function addPauser(address account) public onlyOwner {
        _addPauser(account);
    }

    /** Removes a pauser account
     * @dev Is only callable by owner
     * @param account to be removed
     */
    function removePauser(address account) public onlyOwner {
        _removePauser(account);
    }

    /** Allows privilege holder to renounce their role */
    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    /** Internal implementation of addPauser */
    function _addPauser(address account) internal {
        pausers.add(account);
        emit PauserAdded(account);
    }

    /** Internal implementation of removePauser */
    function _removePauser(address account) internal {
        pausers.remove(account);
        emit PauserRemoved(account);
    }
}
