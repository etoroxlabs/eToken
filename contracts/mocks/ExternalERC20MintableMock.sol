pragma solidity ^0.4.24;

import "../token/ERC20/ExternalERC20Mintable.sol";
import "./MinterRoleMock.sol";

/**
 * @title External ERC20 Mintable mock contract
 * @dev Contract to test out currently unused functions for the
 * external ERC20 mintable contract
 */
contract ExternalERC20MintableMock is  ExternalERC20Mintable, MinterRoleMock {

    constructor(address initMintingRecipient)
        ExternalERC20(new ExternalERC20Storage())
        ExternalERC20Mintable(initMintingRecipient)
        public {
        _externalERC20Storage.transferImplementor(this);
        _externalERC20Storage.transferOwnership(msg.sender);
    }

    /**
     * @dev mints a given amount to a given address
     * @param to address to be minted to
     * @param amount amount to be minted
     */
    function mint(address to, uint256 amount) public {
        _mintExplicitSender(msg.sender, to, amount);
    }

    /**
     * @dev changes set minting recipient to given address
     * @param to address to be set
     */
    function changeMintingRecipient(address to) public {
        _changeMintingRecipient(msg.sender, to);
    }
}
