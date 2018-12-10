pragma solidity ^0.4.24;

/* solium-disable max-len */
import "etokenize-openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Storage.sol";
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Burnable.sol";
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Mintable.sol";
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Pausable.sol";
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "etokenize-openzeppelin-solidity/contracts/access/roles/BurnerRole.sol";
import "../Accesslist.sol";
import "../AccesslistGuarded.sol";
/* solium-enable max-len */

contract EToroTokenImpl is ExternalERC20Mintable,
    ExternalERC20Burnable,
    ExternalERC20Pausable,
    ERC20Detailed,
    AccesslistGuarded,
    BurnerRole {


    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        ExternalERC20Storage externalERC20Storage
    )
        internal
        ExternalERC20(externalERC20Storage)
        ERC20Detailed(name, symbol, decimals)
        AccesslistGuarded(accesslist)
    {
    }

    function transfer(address to, uint256 value)
        public
        requireHasAccess(to)
        onlyHasAccess()
        returns (bool) 
    {
        return super.transfer(to, value);
    }

    function approve(address spender, uint256 value)
        public
        requireHasAccess(spender)
        onlyHasAccess()
        returns (bool) 
    {
        return super.approve(spender, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public
        requireHasAccess(from)
        requireHasAccess(to)
        onlyHasAccess()
        returns (bool) 
    {
        return super.transferFrom(from, to, value);
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        requireHasAccess(spender)
        onlyHasAccess()
        returns (bool) 
    {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        requireHasAccess(spender)
        onlyHasAccess()
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
