pragma solidity ^0.4.24;

import "../token/ERC20/ExternalERC20Burnable.sol";
import "../token/ERC20/ExternalERC20Storage.sol";

/** @title Mock contract for testing ExternalERC20Burnable */
contract ExternalERC20BurnableMock is ExternalERC20Burnable {

    /** @dev Initializes an ERC20Burnable, sets up the external
     * storage and mints an amount of token to the given acount
     * @param initialAccount The account that tokens should be minted to
     * @param initialBalance The amount of tokens that should be mitned
     */
    constructor(address initialAccount, uint256 initialBalance)
        ExternalERC20(new ExternalERC20Storage())
        public
    {
        _externalERC20Storage.transferImplementor(this);
        _externalERC20Storage.transferOwnership(msg.sender);
        _mint(initialAccount, initialBalance);
    }

}
