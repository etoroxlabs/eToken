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

import "../token/IETokenProxy.sol";

/**
 * @title Reverting proxy mock contract
 * @dev Implements a proxy interface which always reverts. Used for
 * testing if upgraded tokens actually forwards calls to the proxy.
 */
contract RevertingProxy is IETokenProxy {

    /* solium-disable zeppelin/missing-natspec-comments */

    function upgrade(IETokenProxy upgradedToken) public pure {
        // Silence warnings
        upgradedToken;
    }

    function finalizeUpgrade() public {
    }

    function nameProxy(address sender)
        public
        view
        returns(string)
    {
        sender;
        revert("name");
    }

    function symbolProxy(address sender)
        public
        view
        returns(string)
    {
        sender;
        revert("symbol");
    }

    function decimalsProxy(address sender)
        public
        view
        returns(uint8)
    {
        // Silence warnings
        sender;
        revert("decimals");
    }

    function totalSupplyProxy(address sender)
        public
        view
        returns(uint256)
    {
        // Silence warnings
        sender;
        revert("totalSupply");
    }

    function balanceOfProxy(address sender, address who)
        public
        view
        returns(uint256)
    {
        // Silence warnings
        sender;
        who;
        revert("balanceOf");
    }

    function allowanceProxy(address sender, address owner, address spender)
        public
        view
        returns(uint256)
    {
        // Silence warnings
        sender;
        owner;
        spender;
        revert("allowance");
    }

    function transferProxy(address sender, address to, uint256 value)
        public
        returns (bool)
    {
        sender;
        to;
        value;
        revert("transfer");
    }

    function approveProxy(address sender, address spender, uint256 value)
        public
        returns (bool)
    {
        sender;
        spender;
        value;
        revert("approve");
    }

    function transferFromProxy(
        address sender,
        address from,
        address to,
        uint256 value
    )
        public
        returns (bool)
    {
        sender;
        from;
        to;
        value;
        revert("transferFrom");
    }

    function increaseAllowanceProxy(
        address sender,
        address spender,
        uint256 addedValue
    )
        public
        returns (bool)
    {
        sender;
        spender;
        addedValue;
        revert("increaseAllowance");
    }

    function decreaseAllowanceProxy(address sender,
                                             address spender,
                                             uint256 subtractedValue)
        public
        returns (bool)  {
        sender;
        spender;
        subtractedValue;
        revert("decreaseAllowance");
    }

    function burnProxy(address sender, uint256 value)
        public
    {
        sender;
        value;
        revert("burn");
    }

    function burnFromProxy(address sender,
                                    address from,
                                    uint256 value)
        public
    {
        sender;
        from;
        value;
        revert("burnFrom");
    }

    function mintProxy(address sender, address to, uint256 value)
        public
        returns (bool)
    {
        sender;
        to;
        value;
        revert("mint");
    }

    function changeMintingRecipientProxy(address sender, address mintingRecip)
        public
    {
        sender;
        mintingRecip;
        revert("changeMintingRecipient");
    }

    function pauseProxy(address sender) external {
        sender;
        revert("pause");
    }

    function unpauseProxy(address sender) external {
        sender;
        revert("unpause");
    }

    function pausedProxy(address sender) external view returns (bool) {
        sender;
        revert("paused");
    }
}
