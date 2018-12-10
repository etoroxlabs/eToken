pragma solidity ^0.4.24;

import "etokenize-openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Storage.sol";
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Burnable.sol";
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Mintable.sol";
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Pausable.sol";
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "etokenize-openzeppelin-solidity/contracts/access/roles/BurnerRole.sol";
import "../Whitelist.sol";
import "../WhitelistGuarded.sol";

contract EToroTokenImpl is ExternalERC20Mintable,
    ExternalERC20Burnable,
    ExternalERC20Pausable,
    ERC20Detailed,
    WhitelistGuarded,
    BurnerRole
{

    Whitelist private whitelist;

    constructor(string name,
                string symbol,
                uint8 decimals,
                address whitelistAddress,
                ExternalERC20Storage externalERC20Storage)
        internal
        ExternalERC20(externalERC20Storage)
        ERC20Detailed(name, symbol, decimals)
        {
            whitelist = Whitelist(whitelistAddress);
        }

    function transfer(address to, uint256 value)
        public
        requireWhitelisted(whitelist, to)
        onlyWhitelisted(whitelist)
        returns (bool)
    {
        return super.transfer(to, value);
    }


    function approve(address spender, uint256 value)
        public
        requireWhitelisted(whitelist, spender)
        onlyWhitelisted(whitelist)
        returns (bool)
    {
        return super.approve(spender, value);
    }


    function transferFrom(address from, address to, uint256 value)
        public
        requireWhitelisted(whitelist, from)
        requireWhitelisted(whitelist, to)
        onlyWhitelisted(whitelist)
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }


    function increaseAllowance(address spender, uint256 addedValue)
        public
        requireWhitelisted(whitelist, spender)
        onlyWhitelisted(whitelist)
        returns (bool)
    {
        return super.increaseAllowance(spender, addedValue);
    }


    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        requireWhitelisted(whitelist, spender)
        onlyWhitelisted(whitelist)
        returns (bool)
    {
        return super.decreaseAllowance(spender, subtractedValue);
    }


    function burn(uint256 value) public onlyBurner {
        super.burn(value);
    }


    function burnFrom(address from, uint256 value) public onlyBurner {
        super.burnFrom(from, value);
    }
}
