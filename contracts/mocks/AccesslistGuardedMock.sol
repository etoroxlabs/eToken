pragma solidity ^0.4.24;

/* solium-disable max-len */
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Storage.sol";
import "../AccesslistGuarded.sol";
/* solium-enable max-len */

contract AccesslistGuardedMock is AccesslistGuarded {

    constructor(Accesslist _accesslist) 
        AccesslistGuarded(_accesslist)
        public 
    {
    }

    function requireNotBlacklisted(address account) 
        public
        view
        requireNotBlacklisted(account)
        returns (bool)
    {
        return true;
    }

    function onlyNotBlacklisted() 
        public
        view
        onlyNotBlacklisted()
        returns (bool)
    {
        return true;
    }

    function requireWhitelist(address account) 
        public
        view
        requireWhitelisted(account)
        returns (bool)
    {
        return true;
    }

    function onlyWhitelist() 
        public
        view
        onlyWhitelisted()
        returns (bool)
    {
        return true;
    }
}
