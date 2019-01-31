pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title External ERC20 Storage
 *
 * @dev The storage contract used in ExternalERC20 token. This contract can
 * provide storage for exactly one contract, referred to as the implementor,
 * inheriting from the ExternalERC20 contract. Only the current implementor or
 * the owner can transfer the implementorship. Change of state is only allowed
 * by the implementor.
 */
contract ExternalERC20Storage is Ownable {

  mapping (address => uint256) public balances;
  mapping (address => mapping (address => uint256)) public allowed;
  uint256 public totalSupply;

  address private _implementor;

  event StorageImplementorTransferred(address indexed from,
                                      address indexed to);

  /**
   * @dev Contructor.
   * @param owner The address of the owner of the contract. 
   * Must not be the zero address.
   * @param implementor The address of the contract that is 
   * allowed to change state. Must not be the zero address.
   */
  constructor(address owner, address implementor) public {

      require(
          owner != address(0),
          "Owner should not be the zero address"
      );

      require(
          implementor != address(0),
          "Implementor should not be the zero address"
      );

      transferOwnership(owner);
      _implementor = implementor;
  }

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
  function setBalance(address owner,
                      uint256 value)
    public
    onlyImplementor
  {
    balances[owner] = value;
  }

  /**
   * @dev Sets new allowance.
   * Can only be called by implementor contract.
   */
  function setAllowed(address owner,
                      address spender,
                      uint256 value)
    public
    onlyImplementor
  {
    allowed[owner][spender] = value;
  }

  /**
   * @dev Change totalSupply.
   * Can only be called by implementor contract.
   */
  function setTotalSupply(uint256 value)
    public
    onlyImplementor
  {
    totalSupply = value;
  }

  /**
   * @dev Transfer implementor to new contract
   * Can only be called by owner or implementor contract.
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
   * @dev Asserts that sender is either owner or implementor.
   */
  modifier onlyImplementorOrOwner() {
    require(isImplementor() || isOwner(), "Is not implementor or owner");
    _;
  }

  /**
   * @dev Asserts that sender is the implementor.
   */
  modifier onlyImplementor() {
    require(isImplementor(), "Is not implementor");
    _;
  }

  /**
   * @dev Asserts that the given address is not the null-address
   */
  modifier requireNonZero(address addr) {
    require(addr != address(0), "Expected a non-zero address");
    _;
  }
}
