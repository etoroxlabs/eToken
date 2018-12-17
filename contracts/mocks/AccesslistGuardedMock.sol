pragma solidity ^0.4.24;

/* solium-disable max-len */
import "../token/ERC20/ExternalERC20Storage.sol";
import "../AccesslistGuarded.sol";
/* solium-enable max-len */

contract AccesslistGuardedMock is AccesslistGuarded {

    constructor(Accesslist _accesslist) 
        AccesslistGuarded(_accesslist)
        public 
    {
    }

    function requireNotBlacklistedMock(address account) 
        public
        view
        requireNotBlacklisted(account)
        returns (bool)
    {
        return true;
    }

    function onlyNotBlacklistedMock() 
        public
        view
        onlyNotBlacklisted()
        returns (bool)
    {
        return true;
    }

    function requireWhitelistedMock(address account) 
        public
        view
        requireWhitelisted(account)
        returns (bool)
    {
        return true;
    }

    function onlyWhitelistedMock() 
        public
        view
        onlyWhitelisted()
        returns (bool)
    {
        return true;
    }
}
