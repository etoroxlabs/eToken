pragma solidity ^0.4.24;

import "../token/ERC20/ExternalERC20Burnable.sol";
import "../token/ERC20/ExternalERC20Storage.sol";

contract ExternalERC20BurnableMock is ExternalERC20Burnable {

  constructor(address initialAccount, uint256 initialBalance)
    ExternalERC20(new ExternalERC20Storage())
    public
  {
    _externalERC20Storage.transferImplementor(this);
    _externalERC20Storage.transferOwnership(msg.sender);
    _mint(initialAccount, initialBalance);
  }

}
