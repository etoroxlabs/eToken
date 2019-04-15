/**
 * MIT License
 *
 * Copyright (c) 2019 eToroX Labs
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

pragma solidity 0.4.24;

import "./IEToken.sol";
import "./ETokenProxy.sol";

/** @title Main EToken contract */
contract EToken is IEToken, ETokenProxy {

    /**
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param decimals The number of decimals of the token
     * @param accesslist Address of a deployed whitelist contract
     * @param whitelistEnabled Create token with whitelist enabled
     * @param externalStorage Address of a deployed ERC20 storage contract
     * @param initialMintingRecipient The initial minting recipient of the token
     * @param upgradedFrom The token contract that this contract upgrades. Set
     * to address(0) for initial deployments
     * @param initialDeployment Set to true if this is the initial deployment of
     * the token. If true it automtically creates a new ExternalERC20Storage.
     * Also, it acts as a confirmation of intention which interlocks
     * upgradedFrom as follows: If initialDeployment is true, then
     * upgradedFrom must be the zero address. Otherwise, upgradedFrom must not
     * be the zero address. The same applies to externalERC20Storage, which must
     * be set to the zero address if initialDeployment is true.
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        Storage externalStorage,
        address initialMintingRecipient,
        address upgradedFrom,
        bool initialDeployment
    )
        public
        ETokenProxy(
            name,
            symbol,
            decimals,
            accesslist,
            whitelistEnabled,
            externalStorage,
            initialMintingRecipient,
            upgradedFrom,
            initialDeployment
        )
    {

    }

    /**
     * @dev Proxies call to new token if this token is upgraded
     * @return the name of the token.
     */
    function name() public view returns(string) {
        if (isUpgraded()) {
            return getUpgradedToken().nameProxy(msg.sender);
        } else {
            return nameGuarded(msg.sender);
        }
    }

    /**
     * @dev Proxies call to new token if this token is upgraded
     * @return the symbol of the token.
     */
    function symbol() public view returns(string) {
        if (isUpgraded()) {
            return getUpgradedToken().symbolProxy(msg.sender);
        } else {
            return symbolGuarded(msg.sender);
        }
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns(uint8) {
        if (isUpgraded()) {
            return getUpgradedToken().decimalsProxy(msg.sender);
        } else {
            return decimalsGuarded(msg.sender);
        }
    }

    /**
     * @dev Proxies call to new token if this token is upgraded
     * @return Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        if (isUpgraded()) {
            return getUpgradedToken().totalSupplyProxy(msg.sender);
        } else {
            return totalSupplyGuarded(msg.sender);
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
            return getUpgradedToken().balanceOfProxy(msg.sender, who);
        } else {
            return balanceOfGuarded(msg.sender, who);
        }
    }

    /**
     * @dev Function to check the amount of tokens that an owner
     * allowed to a spender.
     * @dev Proxies call to new token if this token is upgraded
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available
     * for the spender.
     */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        if (isUpgraded()) {
            return getUpgradedToken().allowanceProxy(
                msg.sender,
                owner,
                spender
            );
        } else {
            return allowanceGuarded(msg.sender, owner, spender);
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
            return getUpgradedToken().transferProxy(msg.sender, to, value);
        } else {
            return transferGuarded(msg.sender, to, value);
        }
    }

    /**
     * @dev Approve the passed address to spend the specified amount
     * of tokens on behalf of msg.sender.  Beware that changing an
     * allowance with this method brings the risk that someone may use
     * both the old and the new allowance by unfortunate transaction
     * ordering. One possible solution to mitigate this race condition
     * is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @dev Proxies call to new token if this token is upgraded
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return getUpgradedToken().approveProxy(msg.sender, spender, value);
        } else {
            return approveGuarded(msg.sender, spender, value);
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
            return getUpgradedToken().transferFromProxy(
                msg.sender,
                from,
                to,
                value
            );
        } else {
            return transferFromGuarded(
                msg.sender,
                from,
                to,
                value
            );
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
            return getUpgradedToken().mintProxy(msg.sender, to, value);
        } else {
            return mintGuarded(msg.sender, to, value);
        }
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @dev Proxies call to new token if this token is upgraded
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        if (isUpgraded()) {
            getUpgradedToken().burnProxy(msg.sender, value);
        } else {
            burnGuarded(msg.sender, value);
        }
    }

    /**
     * @dev Burns a specific amount of tokens from the target address
     * and decrements allowance
     * @dev Proxies call to new token if this token is upgraded
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        if (isUpgraded()) {
            getUpgradedToken().burnFromProxy(msg.sender, from, value);
        } else {
            burnFromGuarded(msg.sender, from, value);
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
            return getUpgradedToken().increaseAllowanceProxy(
                msg.sender,
                spender,
                addedValue
            );
        } else {
            return increaseAllowanceGuarded(msg.sender, spender, addedValue);
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
            return getUpgradedToken().decreaseAllowanceProxy(
                msg.sender,
                spender,
                subtractedValue
            );
        } else {
            return super.decreaseAllowanceGuarded(
                msg.sender,
                spender,
                subtractedValue
            );
        }
    }

    /**
     * @dev Allows the owner to change the current minting recipient account
     * @param mintingRecip address of new minting recipient
     */
    function changeMintingRecipient(address mintingRecip) public {
        if (isUpgraded()) {
            getUpgradedToken().changeMintingRecipientProxy(
                msg.sender,
                mintingRecip
            );
        } else {
            changeMintingRecipientGuarded(msg.sender, mintingRecip);
        }
    }

    /**
     * Allows a pauser to pause the current token.
     */
    function pause() public {
        if (isUpgraded()) {
            getUpgradedToken().pauseProxy(msg.sender);
        } else {
            pauseGuarded(msg.sender);
        }
    }

    /**
     * Allows a pauser to unpause the current token.
     */
    function unpause() public {
        if (isUpgraded()) {
            getUpgradedToken().unpauseProxy(msg.sender);
        } else {
            unpauseGuarded(msg.sender);
        }
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        if (isUpgraded()) {
            return getUpgradedToken().pausedProxy(msg.sender);
        } else {
            return pausedGuarded(msg.sender);
        }
    }
}
