pragma solidity ^0.4.24;

import "../token/ERC20/ExternalERC20Pausable.sol";
import "../token/ERC20/ExternalERC20Storage.sol";
import "./PauserRoleMock.sol";

/**
 * @title Mock contract for testing MinterRole
 */
contract ExternalERC20PausableMock is ExternalERC20Pausable, PauserRoleMock {

    /**
     * @dev Initializes an ERC20Pausable, sets up the external
     * storage and mints an amount of token to the given account
     * @param initialAccount The account that tokens should be minted to
     * @param initialBalance The amount of tokens that should be minted
     */
    constructor(address initialAccount, uint initialBalance)
        ExternalERC20(new ExternalERC20Storage())
        public
    {
        _mint(initialAccount, initialBalance);
    }
}
