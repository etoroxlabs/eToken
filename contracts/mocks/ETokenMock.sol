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

import "../token/ERC20/Storage.sol";
import "../token/EToken.sol";
import "../token/IETokenProxy.sol";
import "./PauserRoleMock.sol";

/** @title Mock contract for testing EToken */
contract ETokenMock is EToken, PauserRoleMock {

    /**
     * Initializes an EToken contract and optionally mint some amount to a
     * given account
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param decimals The number of decimals of the token
     * @param accesslist Address of a deployed whitelist contract
     * @param whitelistEnabled Create token with whitelist enabled
     * @param stor Address of a deployed ERC20 storage contract
     * @param mintingRecip The initial minting recipient for the token
     * @param upgradedFrom The token contract that this contract upgrades. Set
     * to address(0) for initial deployments
     * @param initialDeployment Set to true if this is the initial deployment of
     * the token. Acts as a confirmation of intention which interlocks
     * upgradedFrom as follows: If initialDeployment is true, then
     * upgradedFrom must be the zero address. Otherwise, upgradedFrom must not
     * be the zero address.
     * @param initialAccount The account that should be minted to upon creation.
     * set to 0 for no minting
     * @param initialBalance If minting upon creation, this balance will be minted
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        Storage stor,
        address mintingRecip,
        IETokenProxy upgradedFrom,
        bool initialDeployment,
        address initialAccount,
        uint256 initialBalance
    )
        EToken(
            name, symbol, decimals,
            accesslist, whitelistEnabled, stor, mintingRecip, upgradedFrom,
            initialDeployment
        )
        public
    {
        if (initialAccount != address(0)) {
            _mint(initialAccount, initialBalance);
        }
    }

}
