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

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/** @title Contract managing the whitelist admin role */
contract WhitelistAdminRole is Ownable {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private whitelistAdmins;

    constructor() internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender), "not whitelistAdmin");
        _;
    }

    modifier requireWhitelistAdmin(address account) {
        require(isWhitelistAdmin(account), "not whitelistAdmin");
        _;
    }

    /**
     * @dev Checks if account is whitelist dmin
     * @param account Account to check
     * @return Boolean indicating if account is whitelist admin
     */
    function isWhitelistAdmin(address account) public view returns (bool) {
        return whitelistAdmins.has(account);
    }

    /**
     * @dev Adds a whitelist admin account. Is only callable by owner.
     * @param account Address to be added
     */
    function addWhitelistAdmin(address account) public onlyOwner {
        _addWhitelistAdmin(account);
    }

    /**
     * @dev Removes a whitelist admin account. Is only callable by owner.
     * @param account Address to be removed
     */
    function removeWhitelistAdmin(address account) public onlyOwner {
        _removeWhitelistAdmin(account);
    }

    /** @dev Allows a privileged holder to renounce their role */
    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    /** @dev Internal implementation of addWhitelistAdmin */
    function _addWhitelistAdmin(address account) internal {
        whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    /** @dev Internal implementation of removeWhitelistAdmin */
    function _removeWhitelistAdmin(address account) internal {
        whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}
