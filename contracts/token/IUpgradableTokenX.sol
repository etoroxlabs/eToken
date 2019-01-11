pragma solidity ^0.4.24;


/** @title Interface of an upgradable token
  * @dev See implementation for 
  */
contract IUpgradableTokenX {

    event Transfer(address indexed from,
                   address indexed to,
                   uint256 value);

    event Approval(address indexed owner,
                   address indexed spender,
                   uint256 value);


    /* solium-disable zeppelin/missing-natspec-comments */

    function finalizeUpgrade() external;

    /* Taken from ERC20Detailed in openzeppelin-solidity */
    function nameExplicitSender(address sender) public view returns(string);

    function symbolExplicitSender(address sender) public view returns(string);

    function decimalsExplicitSender(address sender) public view returns(uint8);

    /* Taken from IERC20 in openzeppelin-solidity */
    function totalSupplyExplicitSender(address sender)
        public
        view
        returns (uint256);

    function balanceOfExplicitSender(address sender, address who)
        public
        view
        returns (uint256);

    function allowanceExplicitSender(address sender,
                                     address owner,
                                     address spender)
        public
        view
        returns (uint256);

    function transferExplicitSender(address sender, address to, uint256 value)
        public
        returns (bool);

    function approveExplicitSender(address sender,
                                   address spender,
                                   uint256 value)
        public
        returns (bool);

    function transferFromExplicitSender(address sender,
                                        address from,
                                        address to,
                                        uint256 value)
        public
        returns (bool);

    function mintExplicitSender(address sender, address to, uint256 value)
        public
        returns (bool);

    function changeMintingRecipientExplicitSender(address sender,
                                                  address mintingRecip)
        public;

    function burnExplicitSender(address sender, uint256 value) public;

    function burnFromExplicitSender(address sender,
                                    address from,
                                    uint256 value)
        public;

    function increaseAllowanceExplicitSender(address sender,
                                             address spender,
                                             uint addedValue)
        public
        returns (bool success);

    function decreaseAllowanceExplicitSender(address sender,
                                             address spender,
                                             uint subtractedValue)
        public
        returns (bool success);

}
