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

import "./IETokenProxy.sol";

/**
 * @title EToken interface
 * @dev The interface comprising an EToken contract
 * This interface is a superset of the ERC20 interface defined at
 * https://github.com/ethereum/EIPs/issues/20
 */
interface IEToken {

    /* solium-disable zeppelin/missing-natspec-comments */

    function upgrade(IETokenProxy upgradedToken) external;

    /* Taken from ERC20Detailed in openzeppelin-solidity */
    function name() external view returns(string);

    function symbol() external view returns(string);

    function decimals() external view returns(uint8);

    /* Taken from IERC20 in openzeppelin-solidity */
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
        external
        returns (bool);

    function transferFrom(address from, address to, uint256 value)
        external
        returns (bool);

    /* Taken from ERC20Mintable */
    function mint(address to, uint256 value) external returns (bool);

    /* Taken from ERC20Burnable */
    function burn(uint256 value) external;

    function burnFrom(address from, uint256 value) external;

    /* Taken from ERC20Pausable */
    function increaseAllowance(
        address spender,
        uint addedValue
    )
        external
        returns (bool success);

    function pause() external;

    function unpause() external;

    function paused() external view returns (bool);

    function decreaseAllowance(
        address spender,
        uint subtractedValue
    )
        external
        returns (bool success);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

}
