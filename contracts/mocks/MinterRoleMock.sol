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

import "../token/access/roles/MinterRole.sol";

/**
 * @title Mock contract for testing MinterRole
 */
contract MinterRoleMock is MinterRole {

    /** Tests the msg.sender-dependent onlyMinter modifier */
    function onlyMinterMock() public view onlyMinter {
    }

    /**
     * Tests the requireMinter modifier which checks if the
     * given address is a minter
     * @param a The address to be checked
     */
    function requireMinterMock(address a) public view requireMinter(a) {
    }

    /** Causes compilation errors if _removeMinter function is not declared internal */
    function _removeMinter(address account) internal {
        super._removeMinter(account);
    }

    /** Causes compilation errors if _addMinter function is not declared internal */
    function _addMinter(address account) internal {
        super._addMinter(account);
    }
}
