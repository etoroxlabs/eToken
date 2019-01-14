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

    /**
     * @dev constructor. Sets minting recipient to given address
     * @param _mintingRecipientAccount address to be set to recipient
     */
    constructor(address _mintingRecipientAccount) internal {
        _changeMintingRecipient(msg.sender, _mintingRecipientAccount);
    }

    /**
     * @return The current minting recipient account address
     */
    function getMintingRecipientAccount() public view returns (address) {
        return mintingRecipientAccount;
    }

    /**
     * @dev Internal function allowing the owner to change the current minting recipient account
     * @param sender The sender address of the request
     * @param _mintingRecipientAccount address of new minting recipient
     */
    function _changeMintingRecipient(
        address sender,
        address _mintingRecipientAccount
    )
        internal
    {
        require(owner() == sender, "is not owner");
        require(_mintingRecipientAccount != address(0),
                "zero minting recipient");
        address prev = mintingRecipientAccount;
        mintingRecipientAccount = _mintingRecipientAccount;
        emit MintingRecipientAccountChanged(prev, mintingRecipientAccount);
    }

    /**
     * @dev Function to mint tokens
     * @param sender the sender address of the requiest
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
