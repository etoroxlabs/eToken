pragma solidity ^0.4.24;

import "../token/ERC20/ExternalERC20.sol";
import "../token/ERC20/ExternalERC20Storage.sol";

// mock class using ERC20
contract ExternalERC20Mock is ExternalERC20 {

  constructor(address initialAccount, uint256 initialBalance)
    ExternalERC20(new ExternalERC20Storage())
    public {
    _externalERC20Storage.transferImplementor(this);
    _externalERC20Storage.transferOwnership(msg.sender);
    _mint(initialAccount, initialBalance);
  }

  function mint(address account, uint256 amount) public {
    _mint(account, amount);
  }

  function burn(address account, uint256 amount) public {
    _burn(account, amount);
  }

  function burnFrom(address account, uint256 amount) public {
    _burnFrom(msg.sender, account, amount);
  }

  // Fails if any of the following functions are not declared as internal
  function _approve(address originSender, address spender, uint256 value) internal {
    super._approve(originSender, spender, value);
  }

  function _transferFrom(address originSender, address from, address to, uint256 value) internal {
    super._transferFrom(originSender, from, to, value);
  }

  function _increaseAllowance(address originSender, address spender, uint256 addedValue) internal {
    super._increaseAllowance(originSender, spender, addedValue);
  }

  function _decreaseAllowance(address originSender, address spender, uint256 subtractedValue) internal {
    super._decreaseAllowance(originSender, spender, subtractedValue);
  }

  function _transfer(address from, address to, uint256 value) internal {
    super._transfer(from, to, value);
  }

  function _mint(address account, uint256 value) internal {
    super._mint(account, value);
  }

  function _burn(address account, uint256 value) internal {
    super._burn(account, value);
  }

  function _burnFrom(address burner, address account, uint256 value) internal {
    super._burnFrom(burner, account, value);
  }

  // Functions for testing
  function approvePublicTest(address originSender, address spender, uint256 value) public {
    super._approve(originSender, spender, value);
  }

  function transferFromPublicTest(address originSender, address from, address to, uint256 value) public {
    super._transferFrom(originSender, from, to, value);
  }

  function increaseAllowancePublicTest(address originSender, address spender, uint256 addedValue) public {
    super._increaseAllowance(originSender, spender, addedValue);
  }

  function decreaseAllowancePublicTest(address originSender, address spender, uint256 subtractedValue) public {
    super._decreaseAllowance(originSender, spender, subtractedValue);
  }

  function burnFromPublicTest(address burner, address account, uint256 value) public {
    super._burnFrom(burner, account, value);
  }

}
