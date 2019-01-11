pragma solidity ^0.4.24;

/* solium-disable max-len */
import "../token/ERC20/ExternalERC20Storage.sol";
import "../token/TokenX.sol";
import "../token/IUpgradableTokenX.sol";
import "./PauserRoleMock.sol";

contract TokenXMock is TokenX, PauserRoleMock {

    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        ExternalERC20Storage stor,
        address mintingRecip,
        IUpgradableTokenX upgradedFrom,
        bool initialDeployment,
        address initialAccount,
        uint256 initialBalance
    )
        TokenX(
            name, symbol, decimals,
            accesslist, whitelistEnabled, stor, mintingRecip, upgradedFrom,
            initialDeployment
        )
        public
    {
        if (initialAccount != address(0)) {
            _mint(initialAccount, initialBalance);
        }
    }

}
