pragma solidity ^0.4.24;

import "../token/ERC20/ExternalERC20Pausable.sol";
import "../token/ERC20/ExternalERC20Storage.sol";
import "./PauserRoleMock.sol";

// mock class using ERC20Pausable
contract ExternalERC20PausableMock is ExternalERC20Pausable, PauserRoleMock {

  constructor(address initialAccount, uint initialBalance)
    ExternalERC20(new ExternalERC20Storage())
    public
  {
    _mint(initialAccount, initialBalance);
  }

}
