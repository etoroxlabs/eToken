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

import "../token/ERC20/ERC20.sol";
import "../token/ERC20/Storage.sol";

/**
 * @title External ERC20 mock contract
 * @dev Contract to test out currently unused functions for the
 * external ERC20
 */
contract ERC20Mock is ERC20 {

    /* solium-disable zeppelin/missing-natspec-comments */

    constructor(address initialAccount, uint256 initialBalance,
                Storage _storage, bool isInitialDeployment)
        ERC20("test", "te", 4, _storage, isInitialDeployment)
        public
    {
        if (initialBalance > 0) {
            _mint(initialAccount, initialBalance);
        }
    }

    //
    // Functions for enabling access to internal functions of ERC20
    // from tests
    //

    function name() public view returns(string) {
        return _name();
    }

    function symbol() public view returns(string) {
        return _symbol();
    }

    function decimals() public view returns(uint8) {
        return _decimals();
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply();
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balanceOf(owner);
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowance(owner, spender);
    }

    function transfer(address to, uint256 value)
        public
        returns (bool)
    {
        return _transfer(msg.sender, to, value);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        return _approve(msg.sender, spender, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        returns (bool)
    {
        return _transferFrom(
            msg.sender,
            from,
            to,
            value
        );
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        return _increaseAllowance(msg.sender, spender, addedValue);
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
        public
        returns (bool)
    {
        return _decreaseAllowance(msg.sender, spender, subtractedValue);
    }

    function mint(
        address account,
        uint256 value
    )
        public
        returns (bool)
    {
        return _mint(account, value);
    }

    function burn(
        address from,
        uint256 value
    )
        public
        returns (bool)
    {
        return super._burn(from, value);
    }

    function burnFrom(
        address account,
        uint256 value
    )
        public
        returns (bool)
    {
        return _burnFrom(msg.sender, account, value);
    }

    function approvePublicTest(
        address originSender,
        address spender,
        uint256 value
    )
        public
        returns (bool)
    {
        return _approve(originSender, spender, value);
    }

    function increaseAllowancePublicTest(
        address originSender,
        address spender,
        uint256 addedValue
    )
        public
        returns (bool)
    {
        return _increaseAllowance(originSender, spender, addedValue);
    }

    function decreaseAllowancePublicTest(
        address originSender,
        address spender,
        uint256 subtractedValue
    )
        public
        returns (bool)
    {
        return _decreaseAllowance(originSender, spender, subtractedValue);
    }

    function burnFromPublicTest(
        address originSender,
        address account,
        uint256 value
    )
        public
        returns (bool)
    {
        return _burnFrom(originSender, account, value);
    }

    function transferFromPublicTest(
        address originSender,
        address from,
        address to,
        uint256 value
    )
        public
        returns (bool)
    {
        return _transferFrom(
            originSender,
            from,
            to,
            value
        );
    }

    //
    // Function declarations for ensuring that compilation fails if
    // internal members of ERC20 are not declared internal
    //

    function _name() internal view returns(string) {
        return super._name();
    }

    function _symbol() internal view returns(string) {
        return super._symbol();
    }

    function _decimals() internal view returns(uint8) {
        return super._decimals();
    }

    function _totalSupply() internal view returns (uint256) {
        return super._totalSupply();
    }

    function _balanceOf(address owner) internal view returns (uint256) {
        return super._balanceOf(owner);
    }

    function _allowance(address owner, address spender)
        internal
        view
        returns (uint256)
    {
        return super._allowance(owner, spender);
    }

    function _transfer(address originSender, address to, uint256 value)
        internal
        returns (bool)
    {
        return super._transfer(originSender, to, value);
    }

    function _approve(address originSender, address spender, uint256 value)
        internal
        returns (bool)
    {
        return super._approve(originSender, spender, value);
    }

    function _transferFrom(
        address originSender,
        address from,
        address to,
        uint256 value
    )
        internal
        returns (bool)
    {
        return super._transferFrom(
            originSender,
            from,
            to,
            value
        );
    }

    function _increaseAllowance(
        address originSender,
        address spender,
        uint256 addedValue
    )
        internal
        returns (bool)
    {
        return super._increaseAllowance(
            originSender, spender, addedValue);
    }

    function _decreaseAllowance(
        address originSender,
        address spender,
        uint256 subtractedValue
    )
        internal
        returns (bool)
    {
        return super._decreaseAllowance(
            originSender, spender, subtractedValue);
    }

    function _mint(address account, uint256 value) internal returns (bool) {
        return super._mint(account, value);
    }

    function _burn(address originSender, uint256 value) internal returns (bool)
    {
        return super._burn(originSender, value);
    }

    function _burnFrom(address originSender, address account, uint256 value)
        internal
        returns (bool)
    {
        return super._burnFrom(originSender, account, value);
    }
}
