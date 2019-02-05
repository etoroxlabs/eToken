pragma solidity 0.4.24;

import "./ERC20Mock.sol";

/**
 * @title ERC20 burnable mock contract
 */
contract ERC20BurnableMock is ERC20Mock {

    constructor(
        address initialAccount, uint256 initialBalance,
        Storage _storage, bool isInitialDeployment
    )
        ERC20Mock(initialAccount, initialBalance, _storage, isInitialDeployment)
        public
    {

    }

    /** Interface for testing the internal _burn function */
    function burn(uint256 value) public returns (bool) {
        return super._burn(msg.sender, value);
    }
}
