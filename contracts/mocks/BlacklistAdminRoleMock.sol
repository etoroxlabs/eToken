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

import "../token/access/roles/BlacklistAdminRole.sol";

/**
 * @title An Blacklist admin mock contract
 * @dev Contract to test currently unused modifiers and functions for
 * the blacklist administrator role
 */
contract BlacklistAdminRoleMock is BlacklistAdminRole {

    /** @dev Tests the msg.sender-dependent onlyBlacklistAdmin modifier */
    function onlyBlacklistAdminMock() public view onlyBlacklistAdmin {
    }

    /**
     * @dev Tests the requireBlacklistAdmin modifier which checks if the
     * given address is a blacklist admin
     * @param a Address to be checked
     */
    function requireBlacklistAdminMock(address a)
        public
        view
        requireBlacklistAdmin(a)
    {
    }

    /** @dev Causes compilation errors if _removeBlacklistAdmin function is not declared internal */
    function _removeBlacklistAdmin(address account) internal {
        super._removeBlacklistAdmin(account);
    }

    /** @dev Causes compilation errors if _removeBlacklistAdmin function is not declared internal */
    function _addBlacklistAdmin(address account) internal {
        super._addBlacklistAdmin(account);
    }
}
