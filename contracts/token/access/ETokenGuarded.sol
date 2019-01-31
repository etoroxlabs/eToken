pragma solidity 0.4.24;

import "lifecycle/Pausable.sol";

contract ETokenGuarded {
    /**
     * @dev Like EToken.name, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function nameGuarded(address sender)
        internal
        view
        returns(string)
    {
        // Silence warnings
        sender;
        return _name();
    }

    /**
     * @dev Like EToken.symbol, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function symbolGuarded(address sender)
        internal
        view
        isEnabled
        returns(string)
    {
        // Silence warnings
        sender;
        return _symbol();
    }

    /**
     * @dev Like EToken.decimal, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function decimalsGuarded(address sender)
        internal
        view
        isEnabled
        returns(uint8)
    {
        // Silence warnings
        sender;
        return _decimals();
    }

    /**
     * @dev Like EToken.totalSupply, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function totalSupplyGuarded(address sender)
        internal
        view
        isEnabled
        returns(uint256)
    {
        sender;
        return _totalSupply();
    }

    /**
     * @dev Like EToken.balanceOf, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function balanceOfGuarded(address sender, address who)
        internal
        view
        isEnabled
        senderIsProxy
        returns(uint256)
    {
        // Silence warnings
        sender;
        return _balanceOf(who);
    }

    /**
     * @dev Like EToken.allowance, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function allowanceGuarded(address sender, address owner, address spender)
        internal
        view
        isEnabled
        returns(uint256)
    {
        return _allowance(owner, spender);
    }

    /**
     * @dev Like EToken.transfer, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function transferGuarded(address sender, address to, uint256 value)
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(to)
        requireHasAccess(sender)
        returns (bool)
    {
        _transfer(sender, to, value);
        return true;
    }

    /**
     * @dev Like EToken.approve, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function approveGuarded(address sender, address spender, uint256 value)
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(sender)
        returns (bool)
    {
        _approve(sender, spender, value);
        return true;
    }


    /**
     * @dev Like EToken.transferFrom, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function transferFromGuarded(
        address sender,
        address from,
        address to,
        uint256 value
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(from)
        requireHasAccess(to)
        requireHasAccess(sender)
        returns (bool)
    {
        _transferFrom(
            sender,
            from,
            to,
            value
        );
    }
    return true;
    }


    /**
     * @dev Like EToken.increaseAllowance, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function increaseAllowanceGuarded(
        address sender,
        address spender,
        uint256 addedValue
    )
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(sender)
        returns (bool)
    {
        _increaseAllowance(sender, spender, addedValue);
        return true;
    }

    /**
     * @dev Like EToken.decreaseAllowance, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function decreaseAllowanceGuarded(address sender,
                                             address spender,
                                             uint256 subtractedValue)
        internal
        isEnabled
        whenNotPaused
        requireHasAccess(spender)
        requireHasAccess(sender)
        returns (bool)  {
        _decreaseAllowance(sender, spender, subtractedValue);
        return true;
    }

    /**
     * @dev Like EToken.burn, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function burnGuarded(address sender, uint256 value)
        internal
        isEnabled
        senderIsProxy
        requireBurner(sender)
    {
        _burn(sender, value);
    }

    /**
     * @dev Like EToken.burnFrom, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function burnFromGuarded(address sender,
                                    address from,
                                    uint256 value)
        internal
        isEnabled
        senderIsProxy
        requireBurner(sender)
    {
        _burnFrom(sender, from, value);
    }

    /**
     * @dev Like EToken.mint, but gets sender from explicit sender
     * parameter rather than msg.sender. This function can only be
     * called from the proxy contract (the contract that this contract
     * upgraded).
     */
    function mintGuarded(address sender, address to, uint256 value)
        internal
        isEnabled
        senderIsProxy
        returns (bool success)
    {
        _mintGuarded(sender, to, value);
        return true;
    }

    /**
     * @dev Like EToken.changeMintingRecipient, but gets sender from
     * explicit sender parameter rather than msg.sender. This function
     * can only be called from the proxy contract (the contract that
     * this contract upgraded).
     */
    function changeMintingRecipientGuarded(address sender, address mintingRecip)
        internal
        isEnabled
        senderIsProxy
    {
        _changeMintingRecipient(sender, mintingRecip);
    }
}