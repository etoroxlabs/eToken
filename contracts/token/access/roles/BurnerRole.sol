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

/** @title Contract managing the burner role */
contract BurnerRole is Ownable {
    using Roles for Roles.Role;

    event BurnerAdded(address indexed account);
    event BurnerRemoved(address indexed account);

    Roles.Role private burners;

    constructor() Ownable() internal {
        _addBurner(msg.sender);
    }

    modifier onlyBurner() {
        require(isBurner(msg.sender), "not burner");
        _;
    }

    modifier requireBurner(address account) {
        require(isBurner(account), "not burner");
        _;
    }

    /**
     * @dev Checks if account is burner
     * @param account Account to check
     * @return Boolean indicating if account is burner
     */
    function isBurner(address account) public view returns (bool) {
        return burners.has(account);
    }

    /**
     * @dev Adds a burner account
     * @dev Is only callable by owner
     * @param account Address to be added
     */
    function addBurner(address account) public onlyOwner {
        _addBurner(account);
    }

    /**
     * @dev Removes a burner account
     * @dev Is only callable by owner
     * @param account Address to be removed
     */
    function removeBurner(address account) public onlyOwner {
        _removeBurner(account);
    }

    /** @dev Allows a privileged holder to renounce their role */
    function renounceBurner() public {
        _removeBurner(msg.sender);
    }

    /** @dev Internal implementation of addBurner */
    function _addBurner(address account) internal {
        burners.add(account);
        emit BurnerAdded(account);
    }

    /** @dev Internal implementation of removeBurner */
    function _removeBurner(address account) internal {
        burners.remove(account);
        emit BurnerRemoved(account);
    }
}
