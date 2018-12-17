pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title External ERC20 Storage
 *
 * @dev The storage contract used in ExternalERC20 token.
 * The storage contract can only work with one ExternalERC20 token
 * at a time, that is the implementor.
 * Only the working ExternalERC20 contract or the owner,
 * can transfer the implementorship.
 */
contract ExternalERC20Storage is Ownable {

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply;

    address private _implementor;

    /**
     * @dev Returns whether the sender is an implementor.
     */
    function isImplementor() public view returns(bool) {
        return msg.sender == _implementor;
    }

    /**
     * @dev Sets new balance.
     * Can only be done by owner or implementor contract.
     */
    function setBalance(
        address owner,
        uint256 value
    )
        public
        onlyImplementorOrOwner
    {
        balances[owner] = value;
    }

    /**
     * @dev Sets new allowance.
     * Can only be done by owner or implementor contract.
     */
    function setAllowed(
        address owner,
        address spender,
        uint256 value
    )
        public
        onlyImplementorOrOwner
    {
        allowed[owner][spender] = value;
    }

    /**
     * @dev Change totalSupply.
     * Can only be done by owner or implementor contract.
     */
    function setTotalSupply(uint256 value)
        public
        onlyImplementorOrOwner
    {
        totalSupply = value;
    }

    /**
     * @dev Transfer implementor to new contract
     * Can only be done by owner or implementor contract.
     */
    function transferImplementor(address newImplementor)
        public
        requireNonZero(newImplementor)
        onlyImplementorOrOwner
    {
        _implementor = newImplementor;
    }

    /**
     * @dev Asserts if sender is neither owner nor implementor.
     */
    modifier onlyImplementorOrOwner() {
        require(isImplementor() || isOwner());
        _;
    }

    /**
     * @dev Asserts if the given address is the null-address
     */
    modifier requireNonZero(address addr) {
        require(addr != address(0));
        _;
    }
}
