pragma solidity 0.4.24;


import "./MinterRoleMock.sol";
import "../token/access/RestrictedMinter.sol";
import "./ERC20Mock.sol";
import "../token/ERC20/Storage.sol";

/**
 * @title External ERC20 Mintable mock contract
 */
contract ERC20MintableMock is ERC20Mock, RestrictedMinter, MinterRoleMock {

    constructor(address initialMintingRecipient)
        ERC20Mock(address(0), 0, Storage(0), true)
        RestrictedMinter(initialMintingRecipient)
        public { }

    /**
     * @dev Mints a given amount to a given address
     * @param to Address to be minted to
     * @param amount Amount to be minted
     */
    function mint(address to, uint256 amount)
        public
        requireMinter(msg.sender)
        requireMintingRecipient(to)
        returns (bool)
    {
        return _mint(to, amount);
    }

    /**
     * @dev Changes set minting recipient to given address
     * @param to Address to be set
     */
    function changeMintingRecipient(address to)
        public
        // FIXME: What are we really testing here? Maybe wrap
        // ETokenGuarded instead or change tests?
        onlyOwner
    {
        _changeMintingRecipient(msg.sender, to);
    }

    /** Triggers compilation error if _changeMintingRecipient
     * function is not declared internal
     */
    function _changeMintingRecipient(
        address sender,
        address mintingRecip
    )
        internal
    {
        super._changeMintingRecipient(sender, mintingRecip);
    }
}
