pragma solidity ^0.4.24;

/* solium-disable max-len */
import "../token/ERC20/ExternalERC20Storage.sol";
import "../AccesslistGuarded.sol";
/* solium-enable max-len */

/**
    @title An AccesslistGuarded mock contract
    @dev Contracts to test currently unused modifiers in AccesslistGuarded
*/

contract AccesslistGuardedMock is AccesslistGuarded {

    constructor(Accesslist _accesslist)
        AccesslistGuarded(_accesslist)
        public
    {
    }

    /**
        @dev Function that returns true if
             given address isn't blacklisted
        @param account Address to check
    */
    function requireNotBlacklistedMock(address account)
        public
        view
        requireNotBlacklisted(account)
        returns (bool)
    {
        return true;
    }

    /**
        @dev Function that returns true if
             message sender isn't blacklisted
    */
    function onlyNotBlacklistedMock()
        public
        view
        onlyNotBlacklisted()
        returns (bool)
    {
        return true;
    }

    /**
        @dev Function that returns true if
             given address is whitelisted
        @param account Address to check
    */
    function requireWhitelistedMock(address account)
        public
        view
        requireWhitelisted(account)
        returns (bool)
    {
        return true;
    }

    /**
        @dev Function that returns true if
             message sender is Whitelisted
    */
    function onlyWhitelistedMock()
        public
        view
        onlyWhitelisted()
        returns (bool)
    {
        return true;
    }
}