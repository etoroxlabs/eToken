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

import "../token/access/roles/PauserRole.sol";

/**
 * @title Mock contract for testing PauserRole
 */
contract PauserRoleMock is PauserRole {

    /** Tests the msg.sender-dependent onlyPauser modifier */
    function onlyPauserMock() public view onlyPauser {
    }

    /**
     * Tests the requirePauser modifier which checks if the
     * given address is a pauser
     * @param a The address to be checked
     */
    function requirePauserMock(address a) public view requirePauser(a) {
    }

    /** Causes compilation errors if _removePauser function is not declared internal */
    function _removePauser(address account) internal {
        super._removePauser(account);
    }

    /** Causes compilation errors if _removePauser function is not declared internal */
    function _addPauser(address account) internal {
        super._addPauser(account);
    }
}
