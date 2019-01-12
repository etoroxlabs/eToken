pragma solidity ^0.4.24;

/** 
 * @title Interface of an upgradable token
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
    function nameExplicitSender(address sender) external view returns(string);

    function symbolExplicitSender(address sender)
        external
        view
        returns(string);

    function decimalsExplicitSender(address sender)
        external
        view
        returns(uint8);

    /* Taken from IERC20 in openzeppelin-solidity */
    function totalSupplyExplicitSender(address sender)
        external
        view
        returns (uint256);

    function balanceOfExplicitSender(address sender, address who)
        external
        view
        returns (uint256);

    function allowanceExplicitSender(address sender,
                                     address owner,
                                     address spender)
        external
        view
        returns (uint256);

    function transferExplicitSender(address sender, address to, uint256 value)
        external
        returns (bool);

    function approveExplicitSender(address sender,
                                   address spender,
                                   uint256 value)
        external
        returns (bool);

    function transferFromExplicitSender(address sender,
                                        address from,
                                        address to,
                                        uint256 value)
        external
        returns (bool);

    function mintExplicitSender(address sender, address to, uint256 value)
        external
        returns (bool);

    function changeMintingRecipientExplicitSender(address sender,
                                                  address mintingRecip)
        external;

    function burnExplicitSender(address sender, uint256 value) external;

    function burnFromExplicitSender(address sender,
                                    address from,
                                    uint256 value)
        external;

    function increaseAllowanceExplicitSender(address sender,
                                             address spender,
                                             uint addedValue)
        external
        returns (bool success);

    function decreaseAllowanceExplicitSender(address sender,
                                             address spender,
                                             uint subtractedValue)
        external
        returns (bool success);

}
