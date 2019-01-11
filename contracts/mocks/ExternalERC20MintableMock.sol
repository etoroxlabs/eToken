pragma solidity ^0.4.24;

import "../token/ERC20/ExternalERC20Mintable.sol";
import "./MinterRoleMock.sol";

contract ExternalERC20MintableMock is  ExternalERC20Mintable, MinterRoleMock {

    constructor(address initMintingRecipient)
        ExternalERC20(new ExternalERC20Storage())
        ExternalERC20Mintable(initMintingRecipient)
        public {
        _externalERC20Storage.transferImplementor(this);
        _externalERC20Storage.transferOwnership(msg.sender);
    }

    function mint(address to, uint256 amount) public {
        _mintExplicitSender(msg.sender, to, amount);
    }

    function changeMintingRecipient(address to) public {
        _changeMintingRecipient(msg.sender, to);
    }
}
