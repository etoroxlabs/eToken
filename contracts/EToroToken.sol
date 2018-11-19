pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "./EToroRole.sol";
import "./KillSwitch.sol";

contract EToroToken is MintableToken, BurnableToken, DetailedERC20, KillSwitch , EToroRole{

    EToroRole private eToroRole;

    constructor(string _name, string _symbol, uint8 _decimals, address eToroRoleAddress) public 
        DetailedERC20(_name, _symbol, _decimals) {
        eToroRole = EToroRole(eToroRoleAddress);
    }

    function transfer(address _to, uint256 _value) public onlyWhitelisted returns (bool) {
        eToroRole.checkWhitelisted(_to);
        return super.transfer(_to, _value);
    }

    function approve(address _spender, uint256 _value) public onlyWhitelisted returns (bool) {
        eToroRole.checkWhitelisted(_spender);
        return super.approve(_spender, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        eToroRole.checkWhitelisted(_from);
        eToroRole.checkWhitelisted(_to);
        return super.transferFrom(_from, _to, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue) public onlyWhitelisted returns (bool) {
        eToroRole.checkWhitelisted(_spender);
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public onlyWhitelisted returns (bool) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    function burn(uint256 _value) public onlyOwner {
        super.burn(_value);
    }

    function mint(address _to, uint256 _value) public onlyOwner returns (bool) {
        eToroRole.checkWhitelisted(_to);
        return super.mint(_to, _value);
    }
}