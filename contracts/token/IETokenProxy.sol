pragma solidity 0.4.24;

/**
 * @title Interface of an upgradable token
 * @dev See implementation for
 */
interface IETokenProxy {

    /* solium-disable zeppelin/missing-natspec-comments */

    /* Taken from ERC20Detailed in openzeppelin-solidity */
    function nameProxy(address sender) external view returns(string);

    function symbolProxy(address sender)
        external
        view
        returns(string);

    function decimalsProxy(address sender)
        external
        view
        returns(uint8);

    /* Taken from IERC20 in openzeppelin-solidity */
    function totalSupplyProxy(address sender)
        external
        view
        returns (uint256);

    function balanceOfProxy(address sender, address who)
        external
        view
        returns (uint256);

    function allowanceProxy(address sender,
                            address owner,
                            address spender)
        external
        view
        returns (uint256);

    function transferProxy(address sender, address to, uint256 value)
        external
        returns (bool);

    function approveProxy(address sender,
                          address spender,
                          uint256 value)
        external
        returns (bool);

    function transferFromProxy(address sender,
                               address from,
                               address to,
                               uint256 value)
        external
        returns (bool);

    function mintProxy(address sender, address to, uint256 value)
        external
        returns (bool);

    function changeMintingRecipientProxy(address sender,
                                         address mintingRecip)
        external;

    function burnProxy(address sender, uint256 value) external;

    function burnFromProxy(address sender,
                           address from,
                           uint256 value)
        external;

    function increaseAllowanceProxy(address sender,
                                    address spender,
                                    uint addedValue)
        external
        returns (bool success);

    function decreaseAllowanceProxy(address sender,
                                    address spender,
                                    uint subtractedValue)
        external
        returns (bool success);

}
