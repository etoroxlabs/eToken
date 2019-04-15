/**
 * MIT License
 *
 * Copyright (c) 2019 eToroX Labs
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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
    {
        paused_ = false;
        emit Unpaused(originSender);
    }
}
