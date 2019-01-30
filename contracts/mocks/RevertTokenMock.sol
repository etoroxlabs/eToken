/* solium-disable */
pragma solidity 0.4.24;

import "../token/IUpgradableEToken.sol";

contract RevertTokenMock is IUpgradableEToken {

    function upgrade(IUpgradableEToken upgradedToken) public {
        // Silence warnings
        upgradedToken;
    }

    function finalizeUpgrade() public {
    }

    function nameExplicitSender(address sender)
        public
        view
        returns(string)
    {
        sender;
        revert("name");
    }

    function symbolExplicitSender(address sender)
        public
        view
        returns(string)
    {
        sender;
        revert("symbol");
    }

    function decimalsExplicitSender(address sender)
        public
        view
        returns(uint8)
    {
        // Silence warnings
        sender;
        revert("decimals");
    }

    function totalSupplyExplicitSender(address sender)
        public
        view
        returns(uint256)
    {
        // Silence warnings
        sender;
        revert("totalSupply");
    }

    function balanceOfExplicitSender(address sender, address who)
        public
        view
        returns(uint256)
    {
        // Silence warnings
        sender;
        who;
        revert("balanceOf");
    }

    function allowanceExplicitSender(address sender, address owner, address spender)
        public
        view
        returns(uint256)
    {
        // Silence warnings
        sender;
        owner;
        spender;
        revert("allowance");
    }

    function transferExplicitSender(address sender, address to, uint256 value)
        public
        returns (bool)
    {
        sender;
        to;
        value;
        revert("transfer");
    }

    function approveExplicitSender(address sender, address spender, uint256 value)
        public
        returns (bool)
    {
        sender;
        spender;
        value;
        revert("approve");
    }

    function transferFromExplicitSender(
        address sender,
        address from,
        address to,
        uint256 value
    )
        public
        returns (bool)
    {
        sender;
        from;
        to;
        value;
        revert("transferFrom");
    }

    function increaseAllowanceExplicitSender(
        address sender,
        address spender,
        uint256 addedValue
    )
        public
        returns (bool)
    {
        sender;
        spender;
        addedValue;
        revert("increaseAllowance");
    }

    function decreaseAllowanceExplicitSender(address sender,
                                             address spender,
                                             uint256 subtractedValue)
        public
        returns (bool)  {
        sender;
        spender;
        subtractedValue;
        revert("decreaseAllowance");
    }

    function burnExplicitSender(address sender, uint256 value)
        public
    {
        sender;
        value;
        revert("burn");
    }

    function burnFromExplicitSender(address sender,
                                    address from,
                                    uint256 value)
        public
    {
        sender;
        from;
        value;
        revert("burnFrom");
    }

    function mintExplicitSender(address sender, address to, uint256 value)
        public
        returns (bool)
    {
        sender;
        to;
        value;
        revert("mint");
    }

    function changeMintingRecipientExplicitSender(address sender, address mintingRecip)
        public
    {
        sender;
        mintingRecip;
        revert("changeMintingRecipient");
    }
}
