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

/**
 * @title Interface of an upgradable token
 * @dev See implementation for
 */
interface IETokenProxy {

    /* solium-disable zeppelin/missing-natspec-comments */

    /* Taken from ERC20Detailed in openzeppelin-solidity */
    function nameProxy(address sender) external view returns(string);

    function symbolProxy(address sender)
        external
        view
        returns(string);

    function decimalsProxy(address sender)
        external
        view
        returns(uint8);

    /* Taken from IERC20 in openzeppelin-solidity */
    function totalSupplyProxy(address sender)
        external
        view
        returns (uint256);

    function balanceOfProxy(address sender, address who)
        external
        view
        returns (uint256);

    function allowanceProxy(address sender,
                            address owner,
                            address spender)
        external
        view
        returns (uint256);

    function transferProxy(address sender, address to, uint256 value)
        external
        returns (bool);

    function approveProxy(address sender,
                          address spender,
                          uint256 value)
        external
        returns (bool);

    function transferFromProxy(address sender,
                               address from,
                               address to,
                               uint256 value)
        external
        returns (bool);

    function mintProxy(address sender, address to, uint256 value)
        external
        returns (bool);

    function changeMintingRecipientProxy(address sender,
                                         address mintingRecip)
        external;

    function burnProxy(address sender, uint256 value) external;

    function burnFromProxy(address sender,
                           address from,
                           uint256 value)
        external;

    function increaseAllowanceProxy(address sender,
                                    address spender,
                                    uint addedValue)
        external
        returns (bool success);

    function decreaseAllowanceProxy(address sender,
                                    address spender,
                                    uint subtractedValue)
        external
        returns (bool success);

    function pauseProxy(address sender) external;

    function unpauseProxy(address sender) external;

    function pausedProxy(address sender) external view returns (bool);

    function finalizeUpgrade() external;
}
