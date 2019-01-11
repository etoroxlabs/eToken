pragma solidity ^0.4.24;

import "./ExternalERC20.sol";
import "../../lifecycle/Pausable.sol";

/**
  * @title ExternalERC20 Pausable token
  * @dev ERC20 modified with pausable transfers.
  */
contract ExternalERC20Pausable is ExternalERC20, Pausable {

    /** Wrapper for ExternalERC20.transfer which requires that the
      * contract is not currently paused
      */
    function transfer(
        address to,
        uint256 value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.transfer(to, value);
    }

    /** Wrapper for ExternalERC20.transferFrom which requires that the
      * contract is not currently paused
      */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

    /** Wrapper for ExternalERC20.approve which requires that the
      * contract is not currently paused
      */
    function approve(
        address spender,
        uint256 value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.approve(spender, value);
    }

    /** Wrapper for ExternalERC20.increaseAllowance which requires
      * that the contract is not currently paused
      */
    function increaseAllowance(
        address spender,
        uint addedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.increaseAllowance(spender, addedValue);
    }

    /** Wrapper for ExternalERC20.decreaseAllowance which requires
      * that the contract is not currently paused
      */
    function decreaseAllowance(
        address spender,
        uint subtractedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}
