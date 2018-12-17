pragma solidity ^0.4.24;

import "./ExternalERC20.sol";

/**
 * @title ExternalERC20 Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ExternalERC20Burnable is ExternalERC20 {

  /**
   * @dev Burns a specific amount of tokens.
   * @param value The amount of token to be burned.
   */
  function burn(uint256 value) public {
    _burn(msg.sender, value);
  }

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param from address The address which you want to send tokens from
   * @param value uint256 The amount of token to be burned
   */
  function burnFrom(address from, uint256 value) public {
    _burnFrom(msg.sender, from, value);
  }
}
