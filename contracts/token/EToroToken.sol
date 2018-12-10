pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Storage.sol";

import "./EToroTokenImpl.sol";
import "./IEToroToken.sol";

contract EToroToken is IEToroToken, EToroTokenImpl {

    IEToroToken private upgradedToken;

    constructor(string name,
                string symbol,
                uint8 decimals,
                address whitelistAddress,
                ExternalERC20Storage externalERC20Storage)
        public
        EToroTokenImpl(name, symbol, decimals,
                       whitelistAddress, externalERC20Storage) {

    }

    function isUpgraded() public view returns (bool) {
        return upgradedToken != IEToroToken(0);
    }

    function upgrade(IEToroToken _upgradedToken) public onlyOwner {
        require(!isUpgraded(), "Token is already upgraded");
        require(_upgradedToken != IEToroToken(0), "Supplied address is null");
        upgradedToken = _upgradedToken;
    }

    function name() public view returns(string) {
        if (isUpgraded()) {
            return upgradedToken.name();
        } else {
            return super.name();
        }
    }

    function symbol() public view returns(string) {
        if (isUpgraded()) {
            return upgradedToken.symbol();
        } else {
            return super.symbol();
        }
    }

    function decimals() public view returns(uint8) {
        if (isUpgraded()) {
            return upgradedToken.decimals();
        } else {
            return super.decimals();
        }
    }

    function totalSupply() public view returns (uint256) {
        if (isUpgraded()) {
            return upgradedToken.totalSupply();
        } else {
            return super.totalSupply();
        }
    }

    function balanceOf(address who) public view returns (uint256) {
        if (isUpgraded()) {
            return upgradedToken.balanceOf(who);
        } else {
            return super.balanceOf(who);
        }
    }

    function allowance(address owner,
                       address spender)
        public view returns (uint256) {
        if (isUpgraded()) {
            return upgradedToken.allowance(owner, spender);
        } else {
            return super.allowance(owner, spender);
        }
    }

    function transfer(address to, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return upgradedToken.transfer(to, value);
        } else {
            return super.transfer(to, value);
        }
    }

    function approve(address spender, uint256 value)
        public returns (bool) {
        if (isUpgraded()) {
            return upgradedToken.approve(spender, value);
        } else {
            return super.approve(spender, value);
        }
    }

    function transferFrom(address from, address to, uint256 value)
        public returns (bool) {
        if (isUpgraded()) {
            return upgradedToken.transferFrom(from, to, value);
        } else {
            return super.transferFrom(from, to, value);
        }
    }

    function mint(address to, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return upgradedToken.mint(to, value);
        } else {
            return super.mint(to, value);
        }
    }

    function burn(uint256 value) public {
        if (isUpgraded()) {
            return upgradedToken.burn(value);
        } else {
            return super.burn(value);
        }
    }

    function burnFrom(address from, uint256 value) public {
        if (isUpgraded()) {
            return upgradedToken.burnFrom(from, value);
        } else {
            return super.burnFrom(from, value);
        }
    }

    function increaseAllowance(address spender,
                               uint addedValue)
        public returns (bool success) {
        if (isUpgraded()) {
            return upgradedToken.increaseAllowance(spender, addedValue);
        } else {
            return super.increaseAllowance(spender, addedValue);
        }
    }

    function decreaseAllowance(address spender,
                               uint subtractedValue)
        public returns (bool success) {
        if (isUpgraded()) {
            return upgradedToken.decreaseAllowance(spender, subtractedValue);
        } else {
            return super.decreaseAllowance(spender, subtractedValue);
        }
    }
}
