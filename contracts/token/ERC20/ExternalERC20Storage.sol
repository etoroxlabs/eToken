pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title External ERC20 Storage
 *
 * @dev The storage contract used in ExternalERC20 token. This contract can
 * provide storage for exactly one contract, referred to as the implementor,
 * inheriting from the ExternalERC20 contract.  Only the current implementor or
 * the owner can transfer the implementorship.
 */
contract ExternalERC20Storage is Ownable {

  mapping (address => uint256) public balances;
  mapping (address => mapping (address => uint256)) public allowed;
  uint256 public totalSupply;

  address private _implementor;

  event StorageInitialImplementorSet(address indexed to);
  event StorageImplementorTransferred(address indexed from, address indexed to);

  /**
   * @dev Returns whether the sender is an implementor.
   */
  function isImplementor() public view returns(bool) {
    return msg.sender == _implementor;
  }

  /**
   * @return Does this storage have a preexisting implementor?
   */
  function hasImplementor() public view returns(bool) {
    return _implementor != address(0);
  }

  /**
   * @dev Oneshot function for setting he initial implementor of a function
   * This is not done in the constructor since we need the storage contract to
   * be created separately and then having the initial implementor set itself as
   * the implementor from its constructor.
   */
  function latchInitialImplementor() public {
    require(_implementor == address(0), "Storage implementor is already set");
    _implementor = msg.sender;
    emit StorageInitialImplementorSet(msg.sender);
  }

  /**
   * @dev Sets new balance.
   * Can only be done by owner or implementor contract.
   */
  function setBalance(address owner,
                      uint256 value)
    public
    onlyImplementorOrOwner
  {
    balances[owner] = value;
  }

  /**
   * @dev Sets new allowance.
   * Can only be done by owner or implementor contract.
   */
  function setAllowed(address owner,
                      address spender,
                      uint256 value)
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
    require(newImplementor != _implementor,
            "Cannot transfer to same implementor as existing");
    address curImplementor = _implementor;
    _implementor = newImplementor;
    emit StorageImplementorTransferred(curImplementor, newImplementor);
  }

  /**
   * @dev Asserts if sender is neither owner nor implementor.
   */
  modifier onlyImplementorOrOwner() {
    require(isImplementor() || isOwner(), "Is not implementor or owner");
    _;
  }

  /**
   * @dev Asserts if the given address is the null-address
   */
  modifier requireNonZero(address addr) {
    require(addr != address(0), "Expected a non-zero address");
    _;
  }
}
