pragma solidity ^0.4.24;

import "./ExternalERC20.sol";
import "../../access/roles/MinterRole.sol";

/**
 * @title ExternalERC20 ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ExternalERC20Mintable is ExternalERC20, MinterRole {

    address private mintingRecipientAccount;

    event MintingRecipientAccountChanged(address prev, address next);

    constructor(address _mintingRecipientAccount) internal {
        _changeMintingRecipient(msg.sender, _mintingRecipientAccount);
    }

    /**
     * @dev Allows the owner to change the current minting recipient account
     * @param _mintingRecipientAccount address of new minting recipient
     */
    function _changeMintingRecipient(
        address sender,
        address _mintingRecipientAccount
    )
        internal
    {
        // XXX: Why doesn't Ownable provide a requireOwner modofier?
        require(owner() == sender, "is not owner");
        require(_mintingRecipientAccount != address(0),
                "zero minting recipient");
        address prev = mintingRecipientAccount;
        mintingRecipientAccount = _mintingRecipientAccount;
        emit MintingRecipientAccountChanged(prev, mintingRecipientAccount);
    }

    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function _mintExplicitSender(
        address sender,
        address to,
        uint256 value
    )
        internal
        requireMinter(sender)
    {
        require(to == mintingRecipientAccount,
                "not minting to mintingRecipientAccount");
        _mint(to, value);
    }
}
