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

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./ERC20/ERC20.sol";

import "./IETokenProxy.sol";

/**
 * @title Functionality supporting contract upgradability
 */
contract UpgradeSupport is Ownable, ERC20 {

    event Upgraded(address indexed to);
    event UpgradeFinalized(address indexed upgradedFrom);

    /**
     * @dev Holds the address of the contract that was upgraded from
     */
    address private _upgradedFrom;
    bool private enabled;
    IETokenProxy private upgradedToken;

    /**
     * @dev Constructor
     * @param initialDeployment Set to true if this is the initial deployment of
     * the token. If true it automtically creates a new ExternalERC20Storage.
     * Also, it acts as a confirmation of intention which interlocks
     * upgradedFrom as follows: If initialDeployment is true, then
     * upgradedFrom must be the zero address. Otherwise, upgradedFrom must not
     * be the zero address. The same applies to externalERC20Storage, which must
     * be set to the zero address if initialDeployment is true.
     * @param upgradedFrom The token contract that this contract upgrades. Set
     * to address(0) for initial deployments
     */
    constructor(bool initialDeployment, address upgradedFrom) internal {
        require((upgradedFrom != address(0) && (!initialDeployment)) ||
                (upgradedFrom == address(0) && initialDeployment),
                "Cannot both be upgraded and initial deployment.");

        if (! initialDeployment) {
            // Pause until explicitly unpaused by upgraded contract
            enabled = false;
            _upgradedFrom = upgradedFrom;
        } else {
            enabled = true;
        }
    }

    modifier upgradeExists() {
        require(_upgradedFrom != address(0),
                "Must have a contract to upgrade from");
        _;
    }

    /**
     * @dev Called by the upgraded contract in order to mark the finalization of
     * the upgrade and activate the new contract
     */
    function finalizeUpgrade()
        external
        upgradeExists
        onlyProxy
    {
        enabled = true;
        emit UpgradeFinalized(msg.sender);
    }

    /**
     * Upgrades the current token
     * @param _upgradedToken The address of the token that this token
     * should be upgraded to
     */
    function upgrade(IETokenProxy _upgradedToken) public onlyOwner {
        require(!isUpgraded(), "Token is already upgraded");
        require(_upgradedToken != IETokenProxy(0),
                "Cannot upgrade to null address");
        require(_upgradedToken != IETokenProxy(this),
                "Cannot upgrade to myself");
        require(getExternalStorage().isImplementor(),
                "I don't own my storage. This will end badly.");

        upgradedToken = _upgradedToken;
        getExternalStorage().transferImplementor(_upgradedToken);
        _upgradedToken.finalizeUpgrade();
        emit Upgraded(_upgradedToken);
    }

    /**
     * @return Is this token upgraded
     */
    function isUpgraded() public view returns (bool) {
        return upgradedToken != IETokenProxy(0);
    }

    /**
     * @return The token that this was upgraded to
     */
    function getUpgradedToken() public view returns (IETokenProxy) {
        return upgradedToken;
    }

    /**
     * @dev Only allow the old contract to access the functions with explicit
     * sender passing
     */
    modifier onlyProxy () {
        require(msg.sender == _upgradedFrom,
                "Proxy is the only allowed caller");
        _;
    }

    /**
     * @dev Allows execution if token is enabled, i.e. it is the
     * initial deployment or is upgraded from a contract which has
     * called the finalizeUpgrade function.
     */
    modifier isEnabled () {
        require(enabled, "Token disabled");
        _;
    }
}
