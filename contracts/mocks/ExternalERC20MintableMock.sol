pragma solidity ^0.4.24;

import "../token/ERC20/ExternalERC20Mintable.sol";
import "./MinterRoleMock.sol";

contract ExternalERC20MintableMock is ExternalERC20Mintable, MinterRoleMock {

    constructor() ExternalERC20(new ExternalERC20Storage()) public {
        _externalERC20Storage.transferImplementor(this);
        _externalERC20Storage.transferOwnership(msg.sender);
    }
}
