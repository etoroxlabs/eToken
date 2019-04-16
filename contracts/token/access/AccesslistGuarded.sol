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

import "./Accesslist.sol";

/**
 * @title The AccesslistGuarded contract
 * @dev Contract containing an accesslist and
 * modifiers to ensure proper access
 */
contract AccesslistGuarded {

    Accesslist private accesslist;
    bool private whitelistEnabled;

    /**
     * @dev Constructor. Checks if the accesslist is a zero address
     * @param _accesslist The access list
     * @param _whitelistEnabled If the whitelist is enabled
     */
    constructor(
        Accesslist _accesslist,
        bool _whitelistEnabled
    )
        public
    {
        require(
            _accesslist != Accesslist(0),
            "Supplied accesslist is null"
        );
        accesslist = _accesslist;
        whitelistEnabled = _whitelistEnabled;
    }

    /**
     * @dev Modifier that requires given address
     * to be whitelisted and not blacklisted
     * @param account address to be checked
     */
    modifier requireHasAccess(address account) {
        require(hasAccess(account), "no access");
        _;
    }

    /**
     * @dev Modifier that requires the message sender
     * to be whitelisted and not blacklisted
     */
    modifier onlyHasAccess() {
        require(hasAccess(msg.sender), "no access");
        _;
    }

    /**
     * @dev Modifier that requires given address
     * to be whitelisted
     * @param account address to be checked
     */
    modifier requireWhitelisted(address account) {
        require(isWhitelisted(account), "no access");
        _;
    }

    /**
     * @dev Modifier that requires message sender
     * to be whitelisted
     */
    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "no access");
        _;
    }

    /**
     * @dev Modifier that requires given address
     * to not be blacklisted
     * @param account address to be checked
     */
    modifier requireNotBlacklisted(address account) {
        require(isNotBlacklisted(account), "no access");
        _;
    }

    /**
     * @dev Modifier that requires message sender
     * to not be blacklisted
     */
    modifier onlyNotBlacklisted() {
        require(isNotBlacklisted(msg.sender), "no access");
        _;
    }

    /**
     * @dev Returns whether account has access.
     * If whitelist is enabled a whitelist check is also made,
     * otherwise it only checks for blacklisting.
     * @param account Address to be checked
     * @return true if address has access or is not blacklisted when whitelist
     * is disabled
     */
    function hasAccess(address account) public view returns (bool) {
        if (whitelistEnabled) {
            return accesslist.hasAccess(account);
        } else {
            return isNotBlacklisted(account);
        }
    }

    /**
     * @dev Returns whether account is whitelisted
     * @param account Address to be checked
     * @return true if address is whitelisted
     */
    function isWhitelisted(address account) public view returns (bool) {
        return accesslist.isWhitelisted(account);
    }

    /**
     * @dev Returns whether account is not blacklisted
     * @param account Address to be checked
     * @return true if address is not blacklisted
     */
    function isNotBlacklisted(address account) public view returns (bool) {
        return !accesslist.isBlacklisted(account);
    }
}
