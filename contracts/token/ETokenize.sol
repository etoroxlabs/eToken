pragma solidity ^0.4.24;

import "./ERC20/ExternalERC20Storage.sol";

import "./ETokenizeExplicitSender.sol";
import "./IETokenize.sol";
import "./IUpgradableETokenize.sol";

/** @title Main TokenX contract */
contract ETokenize is IETokenize, ETokenizeExplicitSender {

    ExternalERC20Storage private externalStorage;
    IUpgradableETokenize public upgradedToken;

    /**
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
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        ExternalERC20Storage externalERC20Storage,
        address mintingRecipientAccount,
        address upgradedFrom,
        bool initialDeployment
    )
        public
        ETokenizeExplicitSender(
            name,
            symbol,
            decimals,
            accesslist,
            whitelistEnabled,
            externalERC20Storage,
            mintingRecipientAccount,
            upgradedFrom,
            initialDeployment
        ) {
        externalStorage = externalERC20Storage;

        if (initialDeployment) {
            externalStorage.latchInitialImplementor();
        }
    }

    event Upgraded(address indexed to);

    /**
     * @return Is this token upgraded
     */
    function isUpgraded() public view returns (bool) {
        return upgradedToken != IUpgradableETokenize(0);
    }

    /**
     * Upgrades the current token
     * @param _upgradedToken The address of the token that this token should be upgraded to
     */
    function upgrade(IUpgradableETokenize _upgradedToken) public onlyOwner {
        require(!isUpgraded(), "Token is already upgraded");
        require(_upgradedToken != IUpgradableETokenize(0),
                "Cannot upgrade to null address");
        require(_upgradedToken != IUpgradableETokenize(this),
                "Cannot upgrade to myself");
        require(externalStorage.isImplementor(),
                "I don't own my storage. This will end badly.");

        upgradedToken = _upgradedToken;
        externalStorage.transferImplementor(_upgradedToken);
        _upgradedToken.finalizeUpgrade();
        emit Upgraded(_upgradedToken);
    }

    /**
     * @dev Proxies call to new token if this token is upgraded
     * @return the name of the token.
     */
    function name() public view returns(string) {
        if (isUpgraded()) {
            return upgradedToken.nameExplicitSender(msg.sender);
        } else {
            return super.name();
        }
    }

    /**
     * @dev Proxies call to new token if this token is upgraded
     * @return the symbol of the token.
     */
    function symbol() public view returns(string) {
        if (isUpgraded()) {
            return upgradedToken.symbolExplicitSender(msg.sender);
        } else {
            return super.symbol();
        }
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns(uint8) {
        if (isUpgraded()) {
            return upgradedToken.decimalsExplicitSender(msg.sender);
        } else {
            return super.decimals();
        }
    }

    /**
     * @dev Proxies call to new token if this token is upgraded
     * @return Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        if (isUpgraded()) {
            return upgradedToken.totalSupplyExplicitSender(msg.sender);
        } else {
            return super.totalSupply();
        }
    }

    /**
     * @dev Gets the balance of the specified address.
     * @dev Proxies call to new token if this token is upgraded
     * @param who The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address who) public view returns (uint256) {
        if (isUpgraded()) {
            return upgradedToken.balanceOfExplicitSender(msg.sender, who);
        } else {
            return super.balanceOf(who);
        }
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @dev Proxies call to new token if this token is upgraded
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        if (isUpgraded()) {
            return upgradedToken.allowanceExplicitSender(msg.sender, owner, spender);
        } else {
            return super.allowance(owner, spender);
        }
    }


    /**
     * @dev Transfer token for a specified address
     * @dev Proxies call to new token if this token is upgraded
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return upgradedToken.transferExplicitSender(msg.sender, to, value);
        } else {
            return super.transfer(to, value);
        }
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @dev Proxies call to new token if this token is upgraded
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return upgradedToken.approveExplicitSender(msg.sender, spender, value);
        } else {
            return super.approve(spender, value);
        }
    }

    /**
     * @dev Transfer tokens from one address to another
     * @dev Proxies call to new token if this token is upgraded
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool)
    {
        if (isUpgraded()) {
            return upgradedToken.transferFromExplicitSender(
                msg.sender,
                from,
                to,
                value
            );
        } else {
            return super.transferFrom(from, to, value);
        }
    }

    /**
     * @dev Function to mint tokens
     * @dev Proxies call to new token if this token is upgraded
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return upgradedToken.mintExplicitSender(msg.sender, to, value);
        } else {
            return super.mint(to, value);
        }
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @dev Proxies call to new token if this token is upgraded
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        if (isUpgraded()) {
            upgradedToken.burnExplicitSender(msg.sender, value);
        } else {
            super.burn(value);
        }
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @dev Proxies call to new token if this token is upgraded
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        if (isUpgraded()) {
            upgradedToken.burnFromExplicitSender(msg.sender, from, value);
        } else {
            super.burnFrom(from, value);
        }
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @dev Proxies call to new token if this token is upgraded
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(
        address spender,
        uint addedValue
    )
        public
        returns (bool success)
    {
        if (isUpgraded()) {
            return upgradedToken.increaseAllowanceExplicitSender(msg.sender, spender, addedValue);
        } else {
            return super.increaseAllowance(spender, addedValue);
        }
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @dev Proxies call to new token if this token is upgraded
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(
        address spender,
        uint subtractedValue
    )
        public
        returns (bool success)
    {
        if (isUpgraded()) {
            return upgradedToken.decreaseAllowanceExplicitSender(msg.sender, spender, subtractedValue);
        } else {
            return super.decreaseAllowance(spender, subtractedValue);
        }
    }

    /**
     * @dev Allows the owner to change the current minting recipient account
     * @param mintingRecip address of new minting recipient
     */
    function changeMintingRecipient(address mintingRecip) public {
        if (isUpgraded()) {
            upgradedToken.changeMintingRecipientExplicitSender(msg.sender, mintingRecip);
        } else {
            super.changeMintingRecipient(mintingRecip);
        }
    }

    /**
     * Allows a pauser to pause the current token.
     * @dev This function will _not_ be proxied to the new
     * token if this token is upgraded
     */
    function pause () public {
        if (isUpgraded()) {
            revert("Token is upgraded. Call pause from new token.");
        } else {
            super.pause();
        }
    }

    /**
     * Allows a pauser to unpause the current token.
     * @dev This function will _not_ be proxied to the new
     * token if this token is upgraded
     */
    function unpause () public {
        if (isUpgraded()) {
            revert("Token is upgraded. Call unpause from new token.");
        } else {
            super.unpause();
        }
    }

}
