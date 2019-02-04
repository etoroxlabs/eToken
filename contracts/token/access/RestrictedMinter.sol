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
    function getMintingRecipientAccount() public view returns (address) {
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
