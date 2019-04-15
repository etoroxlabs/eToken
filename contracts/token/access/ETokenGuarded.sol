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

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./Pausable.sol";
import "../ERC20/ERC20.sol";
import "./AccesslistGuarded.sol";
import "./Accesslist.sol";
import "./roles/BurnerRole.sol";
import "./roles/MinterRole.sol";
import "./RestrictedMinter.sol";
import "./../UpgradeSupport.sol";

/**
 * @title EToken access guards
 * @dev This contract implements access guards for functions comprising
 * the EToken public API. Since these functions may be called through
 * a proxy, access checks does not rely on the implicit value of
 * msg.sender but rather on the originSender parameter which is passed
 * to the functions of this contract. The value of originSender is
 * captured from msg.sender at the initial landing-point of the
 * request.
 */
contract ETokenGuarded is
    Pausable,
    ERC20,
    UpgradeSupport,
    AccesslistGuarded,
    BurnerRole,
    MinterRole,
    RestrictedMinter
{

    modifier requireOwner(address addr) {
        require(owner() == addr, "is not owner");
        _;
    }

    /**
     * @dev Constructor
     * @param name The ERC20 detailed token name
     * @param symbol The ERC20 detailed symbol name
     * @param decimals Determines the number of decimals of this token
     * @param accesslist Address of a deployed whitelist contract
     * @param whitelistEnabled Create token with whitelist enabled
     * @param externalStorage The external storage contract.
     * Should be zero address if shouldCreateStorage is true.
     * @param initialDeployment Defines whether it should
     * create a new external storage. Should be false if
     * externalERC20Storage is defined.
     */
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        Storage externalStorage,
        address initialMintingRecipient,
        bool initialDeployment
    )
        internal
        ERC20(name, symbol, decimals, externalStorage, initialDeployment)
        AccesslistGuarded(accesslist, whitelistEnabled)
        RestrictedMinter(initialMintingRecipient)
    {

    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.name. Also see the general documentation for this
     * contract.
     */
    function nameGuarded(address originSender)
        internal
        view
        returns(string)
    {
        // Silence warnings
        originSender;

        return _name();
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.symbol. Also see the general documentation for this
     * contract.
     */
    function symbolGuarded(address originSender)
        internal
        view
        returns(string)
    {
        // Silence warnings
        originSender;

        return _symbol();
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.decimals. Also see the general documentation for this
     * contract.
     */
    function decimalsGuarded(address originSender)
        internal
        view
        returns(uint8)
    {
        // Silence warnings
        originSender;

        return _decimals();
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.totalSupply. Also see the general documentation for this
     * contract.
     */
    function totalSupplyGuarded(address originSender)
        internal
        view
        isEnabled
        returns(uint256)
    {
        // Silence warnings
        originSender;

        return _totalSupply();
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.balanceOf. Also see the general documentation for this
     * contract.
     */
    function balanceOfGuarded(address originSender, address who)
        internal
        view
        isEnabled
        returns(uint256)
    {
        // Silence warnings
        originSender;

        return _balanceOf(who);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.allowance. Also see the general documentation for this
     * contract.
     */
    function allowanceGuarded(
        address originSender,
        address owner,
        address spender
    )
        internal
        view
        isEnabled
        returns(uint256)
    {
        // Silence warnings
        originSender;

        return _allowance(owner, spender);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.transfer. Also see the general documentation for this
     * contract.
     */
    function transferGuarded(address originSender, address to, uint256 value)
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(to)
        requireHasAccess(originSender)
        returns (bool)
    {
        _transfer(originSender, to, value);
        return true;
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.approve. Also see the general documentation for this
     * contract.
     */
    function approveGuarded(
        address originSender,
        address spender,
        uint256 value
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(originSender)
        returns (bool)
    {
        _approve(originSender, spender, value);
        return true;
    }


    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.transferFrom. Also see the documentation for this
     * contract.
     */
    function transferFromGuarded(
        address originSender,
        address from,
        address to,
        uint256 value
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(originSender)
        requireHasAccess(from)
        requireHasAccess(to)
        returns (bool)
    {
        _transferFrom(
            originSender,
            from,
            to,
            value
        );
        return true;
    }


    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.increaseAllowance, Also see the general documentation
     * for this contract.
     */
    function increaseAllowanceGuarded(
        address originSender,
        address spender,
        uint256 addedValue
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(originSender)
        requireHasAccess(spender)
        returns (bool)
    {
        _increaseAllowance(originSender, spender, addedValue);
        return true;
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.decreaseAllowance. Also see the general documentation
     * for this contract.
     */
    function decreaseAllowanceGuarded(
        address originSender,
        address spender,
        uint256 subtractedValue
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(originSender)
        requireHasAccess(spender)
        returns (bool)  {
        _decreaseAllowance(originSender, spender, subtractedValue);
        return true;
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.burn. Also see the general documentation for this
     * contract.
     */
    function burnGuarded(address originSender, uint256 value)
        internal
        isEnabled
        requireBurner(originSender)
    {
        _burn(originSender, value);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.burnFrom. Also see the general documentation for this
     * contract.
     */
    function burnFromGuarded(address originSender, address from, uint256 value)
        internal
        isEnabled
        requireBurner(originSender)
    {
        _burnFrom(originSender, from, value);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.mint. Also see the general documentation for this
     * contract.
     */
    function mintGuarded(address originSender, address to, uint256 value)
        internal
        isEnabled
        requireMinter(originSender)
        requireMintingRecipient(to)
        returns (bool success)
    {
        // Silence warnings
        originSender;

        _mint(to, value);
        return true;
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.changeMintingRecipient. Also see the general
     * documentation for this contract.
     */
    function changeMintingRecipientGuarded(
        address originSender,
        address mintingRecip
    )
        internal
        isEnabled
        requireOwner(originSender)
    {
        _changeMintingRecipient(originSender, mintingRecip);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.pause. Also see the general documentation for this
     * contract.
     */
    function pauseGuarded(address originSender)
        internal
        isEnabled
        requireIsPauser(originSender)
        whenNotPaused
    {
        _pause(originSender);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.unpause. Also see the general documentation for this
     * contract.
     */
    function unpauseGuarded(address originSender)
        internal
        isEnabled
        requireIsPauser(originSender)
        whenPaused
    {
        _unpause(originSender);
    }

    /**
     * @dev Permission enforcing wrapper around the functionality of
     * EToken.paused. Also see the general documentation for this
     * contract.
     */
    function pausedGuarded(address originSender)
        internal
        view
        isEnabled
        returns (bool)
    {
        // Silence warnings
        originSender;
        return _paused();
    }
}
