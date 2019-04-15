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

import "../token/access/AccesslistGuarded.sol";

/**
 * @title An AccesslistGuarded mock contract
 * @dev Contracts to test currently unused modifiers in AccesslistGuarded
 */
contract AccesslistGuardedMock is AccesslistGuarded {

    constructor(Accesslist _accesslist, bool whitelistEnabled)
        AccesslistGuarded(_accesslist, whitelistEnabled)
        public
    {
    }

    /**
     * @dev Function that returns true if
     * given address has access
     * @param account Address to check
     */
    function requireHasAccessMock(address account)
        public
        view
        requireHasAccess(account)
        returns (bool)
    {
        return true;
    }

    /**
     * @dev Function that returns true if
     * message sender has access
     */
    function onlyHasAccessMock()
        public
        view
        onlyHasAccess
        returns (bool)
    {
        return true;
    }

    /**
     * @dev Function that returns true if
     * given address is whitelisted
     * @param account Address to check
     */
    function requireWhitelistedMock(address account)
        public
        view
        requireWhitelisted(account)
        returns (bool)
    {
        return true;
    }

    /**
     * @dev Function that returns true if
     * message sender is Whitelisted
     */
    function onlyWhitelistedMock()
        public
        view
        onlyWhitelisted
        returns (bool)
    {
        return true;
    }

    /**
     * @dev Function that returns true if
     * given address isn't blacklisted
     * @param account Address to check
     */
    function requireNotBlacklistedMock(address account)
        public
        view
        requireNotBlacklisted(account)
        returns (bool)
    {
        return true;
    }

    /**
     * @dev Function that returns true if
     * message sender isn't blacklisted
     */
    function onlyNotBlacklistedMock()
        public
        view
        onlyNotBlacklisted
        returns (bool)
    {
        return true;
    }
}
