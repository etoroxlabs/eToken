pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./roles/BurnerRole.sol";
import "./Whitelist.sol";
import "./WhitelistGuarded.sol";

contract EToroToken is ERC20Mintable,
    ERC20Burnable,
    ERC20Detailed,
    ERC20Pausable,
    Ownable,
    WhitelistGuarded,
    BurnerRole
{

    Whitelist private whitelist;

    constructor(string _name,
                string _symbol,
                uint8 _decimals,
                address owner,
                address whitelistAddress)
        public
        ERC20Detailed(_name, _symbol, _decimals)
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

    function transfer(address _to, uint256 _value)
        public
        requireWhitelisted(whitelist, _to)
        onlyWhitelisted(whitelist)
        returns (bool)
    {
        return super.transfer(_to, _value);
    }


    function approve(address _spender, uint256 _value)
        public
        requireWhitelisted(whitelist, _spender)
        onlyWhitelisted(whitelist)
        returns (bool)
    {
        return super.approve(_spender, _value);
    }


    function transferFrom(address _from, address _to, uint256 _value)
        public
        requireWhitelisted(whitelist, _from)
        requireWhitelisted(whitelist, _to)
        onlyWhitelisted(whitelist)
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }


    function increaseAllowance(address _spender, uint256 _addedValue)
        public
        requireWhitelisted(whitelist, _spender)
        onlyWhitelisted(whitelist)
        returns (bool)
    {
        return super.increaseAllowance(_spender, _addedValue);
    }


    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
        requireWhitelisted(whitelist, _spender)
        onlyWhitelisted(whitelist)
        returns (bool)
    {
        return super.decreaseAllowance(_spender, _subtractedValue);
    }


    function burn(uint256 _value) public onlyBurner {
        super.burn(_value);
    }

}
