pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./EToroRole.sol";

contract EToroToken is ERC20Mintable, ERC20Burnable, ERC20Detailed, Ownable, EToroRole {

    EToroRole private eToroRole;

    constructor(string _name,
                string _symbol,
                uint8 _decimals,
                address eToroRoleAddress)
        public
        ERC20Detailed(_name, _symbol, _decimals)
        {
            eToroRole = EToroRole(eToroRoleAddress);
        }


    function transfer(address _to, uint256 _value)
        public onlyWhitelisted
        returns (bool)
    {
        eToroRole.checkWhitelisted(_to);
        return super.transfer(_to, _value);
    }


    function approve(address _spender, uint256 _value)
      public onlyWhitelisted
      returns (bool)
    {
      eToroRole.checkWhitelisted(_spender);
        return super.approve(_spender, _value);
    }


    function transferFrom(address _from, address _to, uint256 _value)
      public
      returns (bool)
    {
      require(eToroRole.isWhitelisted(_from));
      require(eToroRole.isWhitelisted(_to));
      return super.transferFrom(_from, _to, _value);
    }


    function increaseAllowance(address _spender, uint256 _addedValue)
        public
        onlyWhitelisted
        returns (bool)
    {
        eToroRole.checkWhitelisted(_spender);
        return super.increaseAllowance(_spender, _addedValue);
    }


    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
        onlyWhitelisted
        returns (bool)
    {
        return super.decreaseAllowance(_spender, _subtractedValue);
    }


    function burn(uint256 _value)
      public onlyOwner
    {
        super.burn(_value);
    }


    function mint(address _to, uint256 _value)
        //public onlyOwner
      returns (bool)
    {
        //eToroRole.checkWhitelisted(_to);
        return super.mint(_to, _value);
    }
}
