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

import "../token/access/roles/BurnerRole.sol";

/**
 * @title Burner role mock contract
 * @dev Contract to test currently unused modifiers and functions for
 * the burner role
 */
contract BurnerRoleMock is BurnerRole {

    /** @dev Tests the msg.sender-dependent onlyBurner modifier */
    function onlyBurnerMock() public view onlyBurner {
    }

    /** @dev Tests the requireBurner modifier which checks if the
     * given address is a blacklist admin
     * @param a The address to be checked
     */
    function requireBurnerMock(address a) public view requireBurner(a) {
    }

    /** @dev Causes compilation errors if _removeBurner function is not declared internal */
    function _removeBurner(address account) internal {
        super._removeBurner(account);
    }

    /** @dev Causes compilation errors if _removeBurner function is not declared internal */
    function _addBurner(address account) internal {
        super._addBurner(account);
    }
}
