pragma solidity ^0.4.24;

/* solium-disable max-len */
import "../token/ERC20/ExternalERC20Storage.sol";
import "../token/TokenX.sol";
import "../token/IUpgradableTokenX.sol";
import "./PauserRoleMock.sol";

/** @title Mock contract for testing TokenX */
contract TokenXMock is TokenX, PauserRoleMock {

    /** Initializes a TokenX contract and optionally mint some amount to a
     * given account
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param decimals The number of decimals of the token
     * @param accesslist Address of a deployed whitelist contract
     * @param whitelistEnabled Create token with whitelist enabled
     * @param externalERC20Storage Address of a deployed ERC20 storage contract
     * @param mintingRecipientAccount The initial minting recipient of the token
     * @param upgradedFrom The token contract that this contract upgrades. Set
     * to address(0) for initial deployments
     * @param initialDeployment Set to true if this is the initial deployment of
     * the token. Acts as a confirmation of intention which interlocks
     * upgradedFrom as follows: If initialDeployment is true, then
     * upgradedFrom must be the zero address. Otherwise, upgradedFrom must not
     * be the zero address.
     * @param initialAccount The account that should be minted to upon creation.
     * set to 0 for no minting
     * @param initialBalance If minting upon creation, this balance will be minted
     */
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
