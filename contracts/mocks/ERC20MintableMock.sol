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


import "./MinterRoleMock.sol";
import "../token/access/RestrictedMinter.sol";
import "./ERC20Mock.sol";
import "../token/ERC20/Storage.sol";

/**
 * @title External ERC20 Mintable mock contract
 */
contract ERC20MintableMock is ERC20Mock, RestrictedMinter, MinterRoleMock {

    constructor(address initialMintingRecipient)
        ERC20Mock(address(0), 0, Storage(0), true)
        RestrictedMinter(initialMintingRecipient)
        public { }

    /**
     * @dev Mints a given amount to a given address
     * @param to Address to be minted to
     * @param amount Amount to be minted
     */
    function mint(address to, uint256 amount)
        public
        // Recreate the public interface of EToken expected by tests
        requireMinter(msg.sender)
        requireMintingRecipient(to)
        returns (bool)
    {
        return _mint(to, amount);
    }

    /**
     * @dev Changes set minting recipient to given address
     * @param to Address to be set
     */
    function changeMintingRecipient(address to)
        public
        // Recreate the public interface of EToken expected by tests
        onlyOwner
    {
        _changeMintingRecipient(msg.sender, to);
    }

    /** Triggers compilation error if _changeMintingRecipient
     * function is not declared internal
     */
    function _changeMintingRecipient(
        address sender,
        address mintingRecip
    )
        internal
    {
        super._changeMintingRecipient(sender, mintingRecip);
    }
}
