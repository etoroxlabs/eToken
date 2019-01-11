pragma solidity ^0.4.24;

import "./ERC20/ExternalERC20Storage.sol";

import "./TokenXExplicitSender.sol";
import "./ITokenX.sol";
import "./IUpgradableTokenX.sol";

contract TokenX is ITokenX, TokenXExplicitSender {

    ExternalERC20Storage private externalStorage;
    IUpgradableTokenX public upgradedToken;

    constructor(
        string name,
        string symbol,
        uint8 decimals,
        Accesslist accesslist,
        bool whitelistEnabled,
        ExternalERC20Storage externalERC20Storage,
        address mintingRecipientAccount,
        address upgradedFrom,
        bool initialDeployment
    )
        public
        TokenXExplicitSender(
            name,
            symbol,
            decimals,
            accesslist,
            whitelistEnabled,
            externalERC20Storage,
            mintingRecipientAccount,
            upgradedFrom,
            initialDeployment
        ) {
        externalStorage = externalERC20Storage;

        if (initialDeployment) {
            externalStorage.latchInitialImplementor();
        }
    }

    event Upgraded(address to);

    function isUpgraded() public view returns (bool) {
        return upgradedToken != IUpgradableTokenX(0);
    }

    function upgrade(IUpgradableTokenX _upgradedToken) public onlyOwner {
        require(!isUpgraded(), "Token is already upgraded");
        require(_upgradedToken != IUpgradableTokenX(0),
                "Cannot upgrade to null address");
        require(_upgradedToken != IUpgradableTokenX(this),
                "Cannot upgrade to myself");
        require(externalStorage.isImplementor(),
                "I don't own my storage. This will end badly.");

        upgradedToken = _upgradedToken;
        externalStorage.transferImplementor(_upgradedToken);
        _upgradedToken.finalizeUpgrade();
        emit Upgraded(_upgradedToken);
    }

    function name() public view returns(string) {
        if (isUpgraded()) {
            return upgradedToken.nameExplicitSender(msg.sender);
        } else {
            return super.name();
        }
    }

    function symbol() public view returns(string) {
        if (isUpgraded()) {
            return upgradedToken.symbolExplicitSender(msg.sender);
        } else {
            return super.symbol();
        }
    }

    function decimals() public view returns(uint8) {
        if (isUpgraded()) {
            return upgradedToken.decimalsExplicitSender(msg.sender);
        } else {
            return super.decimals();
        }
    }

    function totalSupply() public view returns (uint256) {
        if (isUpgraded()) {
            return upgradedToken.totalSupplyExplicitSender(msg.sender);
        } else {
            return super.totalSupply();
        }
    }

    function balanceOf(address who) public view returns (uint256) {
        if (isUpgraded()) {
            return upgradedToken.balanceOfExplicitSender(msg.sender, who);
        } else {
            return super.balanceOf(who);
        }
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        if (isUpgraded()) {
            return upgradedToken.allowanceExplicitSender(msg.sender, owner, spender);
        } else {
            return super.allowance(owner, spender);
        }
    }

    function transfer(address to, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return upgradedToken.transferExplicitSender(msg.sender, to, value);
        } else {
            return super.transfer(to, value);
        }
    }

    function approve(address spender, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return upgradedToken.approveExplicitSender(msg.sender, spender, value);
        } else {
            return super.approve(spender, value);
        }
    }

    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool)
    {
        if (isUpgraded()) {
            return upgradedToken.transferFromExplicitSender(
                msg.sender,
                from,
                to,
                value
            );
        } else {
            return super.transferFrom(from, to, value);
        }
    }

    function mint(address to, uint256 value) public returns (bool) {
        if (isUpgraded()) {
            return upgradedToken.mintExplicitSender(msg.sender, to, value);
        } else {
            return super.mint(to, value);
        }
    }

    function burn(uint256 value) public {
        if (isUpgraded()) {
            upgradedToken.burnExplicitSender(msg.sender, value);
        } else {
            super.burn(value);
        }
    }

    function burnFrom(address from, uint256 value) public {
        if (isUpgraded()) {
            upgradedToken.burnFromExplicitSender(msg.sender, from, value);
        } else {
            super.burnFrom(from, value);
        }
    }

    function increaseAllowance(
        address spender,
        uint addedValue
    )
        public
        returns (bool success)
    {
        if (isUpgraded()) {
            return upgradedToken.increaseAllowanceExplicitSender(msg.sender, spender, addedValue);
        } else {
            return super.increaseAllowance(spender, addedValue);
        }
    }

    function decreaseAllowance(
        address spender,
        uint subtractedValue
    )
        public
        returns (bool success)
    {
        if (isUpgraded()) {
            return upgradedToken.decreaseAllowanceExplicitSender(msg.sender, spender, subtractedValue);
        } else {
            return super.decreaseAllowance(spender, subtractedValue);
        }
    }

    function changeMintingRecipient(address mintingRecip) public {
        if (isUpgraded()) {
            upgradedToken.changeMintingRecipientExplicitSender(msg.sender, mintingRecip);
        } else {
            super.changeMintingRecipient(mintingRecip);
        }
    }

    function pause () public {
        if (isUpgraded()) {
            revert("Token is upgraded. Call pause from new token.");
        } else {
            super.pause();
        }
    }

    function unpause () public {
        if (isUpgraded()) {
            revert("Token is upgraded. Call unpause from new token.");
        } else {
            super.unpause();
        }
    }

}
