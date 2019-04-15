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

/** @title Contract managing the pauser role */
contract PauserRole is Ownable {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private pausers;

    constructor() internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "not pauser");
        _;
    }

    modifier requirePauser(address account) {
        require(isPauser(account), "not pauser");
        _;
    }

    /**
     * @dev Checks if account is pauser
     * @param account Account to check
     * @return Boolean indicating if account is pauser
     */
    function isPauser(address account) public view returns (bool) {
        return pausers.has(account);
    }

    /**
     * @dev Adds a pauser account. Is only callable by owner.
     * @param account Address to be added
     */
    function addPauser(address account) public onlyOwner {
        _addPauser(account);
    }

    /**
     * @dev Removes a pauser account. Is only callable by owner.
     * @param account Address to be removed
     */
    function removePauser(address account) public onlyOwner {
        _removePauser(account);
    }

    /** @dev Allows a privileged holder to renounce their role */
    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    /** @dev Internal implementation of addPauser */
    function _addPauser(address account) internal {
        pausers.add(account);
        emit PauserAdded(account);
    }

    /** @dev Internal implementation of removePauser */
    function _removePauser(address account) internal {
        pausers.remove(account);
        emit PauserRemoved(account);
    }
}
