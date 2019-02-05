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
     * @dev Modifier to make a function callable if a specified account is pauser.
     * @param account the address of the account to check
     */
    modifier requireIsPauser(address account) {
        require(isPauser(account));
        _;
    }

    /**
     * @dev Called by the owner to pause, triggers stopped state
     * @param originSender the original sender of this method
     */
    function _pause(address originSender)
        internal
        requireIsPauser(originSender)
        whenNotPaused
    {
        paused_ = true;
        emit Paused(originSender);
    }

    /**
     * @dev Called by the owner to unpause, returns to normal state
     * @param originSender the original sender of this method
     */
    function _unpause(address originSender)
        internal
        requireIsPauser(originSender)
        whenPaused
    {
        paused_ = false;
        emit Unpaused(originSender);
    }
}
