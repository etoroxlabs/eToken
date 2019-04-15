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

/**
 * @title Restricted minter
 * @dev Implements the notion of a restricted minter which is only
 * able to mint to a single specified account. Only the owner may
 * change this account.
 */
contract RestrictedMinter  {

    address private mintingRecipientAccount;

    event MintingRecipientAccountChanged(address prev, address next);

    /**
     * @dev constructor. Sets minting recipient to given address
     * @param _mintingRecipientAccount address to be set to recipient
     */
    constructor(address _mintingRecipientAccount) internal {
        _changeMintingRecipient(msg.sender, _mintingRecipientAccount);
    }

    modifier requireMintingRecipient(address account) {
        require(account == mintingRecipientAccount,
                "is not mintingRecpientAccount");
        _;
    }

    /**
     * @return The current minting recipient account address
     */
    function getMintingRecipient() public view returns (address) {
        return mintingRecipientAccount;
    }

    /**
     * @dev Internal function allowing the owner to change the current minting recipient account
     * @param originSender The sender address of the request
     * @param _mintingRecipientAccount address of new minting recipient
     */
    function _changeMintingRecipient(
        address originSender,
        address _mintingRecipientAccount
    )
        internal
    {
        originSender;

        require(_mintingRecipientAccount != address(0),
                "zero minting recipient");
        address prev = mintingRecipientAccount;
        mintingRecipientAccount = _mintingRecipientAccount;
        emit MintingRecipientAccountChanged(prev, mintingRecipientAccount);
    }

}
