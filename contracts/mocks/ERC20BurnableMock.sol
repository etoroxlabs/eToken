pragma solidity 0.4.24;

import "./ERC20Mock.sol";

/**
 * @title External ERC20 mock contract
 * @dev Contract to test out currently unused functions for the
 * external ERC20
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

    function burn(uint256 value) public returns (bool) {
        return super._burn(msg.sender, value);
    }
}
