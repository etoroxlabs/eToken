pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Storage.sol";
import "openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Pausable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/access/roles/BurnerRole.sol";
import "./Whitelist.sol";
import "./WhitelistGuarded.sol";

contract EToroToken is ExternalERC20Mintable,
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
                address owner,
                address whitelistAddress,
                ExternalERC20Storage externalERC20Storage)
        public
        ExternalERC20(externalERC20Storage)
        ERC20Detailed(name, symbol, decimals)
        {
            whitelist = Whitelist(whitelistAddress);
            addMinter(owner);
            renounceMinter();
            addPauser(owner);
            renouncePauser();
            addBurner(owner);
            renounceBurner();
            transferOwnership(owner);
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

}
