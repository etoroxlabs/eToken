pragma solidity ^0.4.24;

import "./IUpgradableETokenize.sol";

/**
 * @title eTokenize interface
 * @dev The interface comprising a eTokenize contract
 */
interface IETokenize {

    /* solium-disable zeppelin/missing-natspec-comments */

    function upgrade(IUpgradableETokenize upgradedToken) external;

    /* Taken from ERC20Detailed in openzeppelin-solidity */
    function name() external view returns(string);

    function symbol() external view returns(string);

    function decimals() external view returns(uint8);

    /* Taken from IERC20 in openzeppelin-solidity */
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
        external
        returns (bool);

    function transferFrom(address from, address to, uint256 value)
        external
        returns (bool);

    /* Taken from ERC20Mintable */
    function mint(address to, uint256 value) external returns (bool);

    /* Taken from ERC20Burnable */
    function burn(uint256 value) external;

    function burnFrom(address from, uint256 value) external;

    /* Taken from ERC20Pausable */
    function increaseAllowance(
        address spender,
        uint addedValue
    )
        external
        returns (bool success);

    function decreaseAllowance(
        address spender,
        uint subtractedValue
    )
        external
        returns (bool success);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

}
