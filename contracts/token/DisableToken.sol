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

pragma solidity ^0.4.24;

import "./IETokenProxy.sol";

/**
 * @title A token that doesn't work
 * @dev Implements a proxy interface which always reverts. Used for
 * testing if upgraded tokens actually forwards calls to the proxy.
 */
contract DisableToken is IETokenProxy {

    /* solium-disable zeppelin/missing-natspec-comments */

    function upgrade(IETokenProxy upgradedToken) public pure {
        // Silence warnings
        upgradedToken;
        revert("Token is disabled");
    }

    function finalizeUpgrade() public {
    }

    function nameProxy(address sender)
        public
        view
        returns(string)
    {
        sender;
        return "DO NOT USE - Disabled";
    }

    function symbolProxy(address sender)
        public
        view
        returns(string)
    {
        sender;
        return "DEAD";
    }

    function decimalsProxy(address sender)
        public
        view
        returns(uint8)
    {
        // Silence warnings
        sender;
        return 0;
    }

    function totalSupplyProxy(address sender)
        public
        view
        returns(uint256)
    {
        // Silence warnings
        sender;
        return 0;
    }

    function balanceOfProxy(address sender, address who)
        public
        view
        returns(uint256)
    {
        // Silence warnings
        sender;
        who;
        return 0;
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
        return 0;
    }

    function transferProxy(address sender, address to, uint256 value)
        public
        returns (bool)
    {
        sender;
        to;
        value;
        revert("Token is disabled");
    }

    function approveProxy(address sender, address spender, uint256 value)
        public
        returns (bool)
    {
        sender;
        spender;
        value;
        revert("Token is disabled");
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
        revert("Token is disabled");
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
        revert("Token is disabled");
    }

    function decreaseAllowanceProxy(address sender,
                                    address spender,
                                    uint256 subtractedValue)
        public
        returns (bool)  {
        sender;
        spender;
        subtractedValue;
        revert("Token is disabled");
    }

    function burnProxy(address sender, uint256 value)
        public
    {
        sender;
        value;
        revert("Token is disabled");
    }

    function burnFromProxy(address sender,
                           address from,
                           uint256 value)
        public
    {
        sender;
        from;
        value;
        revert("Token is disabled");
    }

    function mintProxy(address sender, address to, uint256 value)
        public
        returns (bool)
    {
        sender;
        to;
        value;
        revert("Token is disabled");
    }

    function changeMintingRecipientProxy(address sender, address mintingRecip)
        public
    {
        sender;
        mintingRecip;
        revert("Token is disabled");
    }

    function pauseProxy(address sender) external {
        sender;
        revert("Token is disabled");
    }

    function unpauseProxy(address sender) external {
        sender;
        revert("Token is disabled");
    }

    function pausedProxy(address sender) external view returns (bool) {
        sender;
        revert("Token is disabled");
    }
}
