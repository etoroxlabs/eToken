pragma solidity 0.4.24;

import "./roles/PauserRole.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private paused_;

    constructor() internal {
        paused_ = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function _paused() internal view returns(bool) {
        return paused_;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused_);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused_);
        _;
    }

    /**
     * @dev Called by the owner to pause, triggers stopped state
     */
    function _pause() internal onlyPauser whenNotPaused {
        paused_ = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by the owner to unpause, returns to normal state
     */
    function _unpause() internal onlyPauser whenPaused {
        paused_ = false;
        emit Unpaused(msg.sender);
    }
}
