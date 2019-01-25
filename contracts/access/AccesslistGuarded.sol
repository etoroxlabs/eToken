pragma solidity 0.4.24;

import "./Accesslist.sol";

/**
 * @title The AccesslistGuarded contract
 * @dev Contract containing an accesslist and
 * modifiers to ensure proper access
 */
contract AccesslistGuarded {

    Accesslist private accesslist;
    bool public whitelistEnabled;

    /**
     * @dev Constructor. Checks if the accesslist is a zero address
     * @param _accesslist The access list
     * @param _whitelistEnabled If the whitelist is enabled
     */
    constructor(
        Accesslist _accesslist,
        bool _whitelistEnabled
    )
        public
    {
        require(
            _accesslist != Accesslist(0),
            "Supplied accesslist is null"
        );
        accesslist = _accesslist;
        whitelistEnabled = _whitelistEnabled;
    }

    /**
     * @dev Modifier that requires given address
     * to be whitelisted and not blacklisted
     * @param account address to be checked
     */
    modifier requireHasAccess(address account) {
        require(hasAccess(account), "no access");
        _;
    }

    /**
     * @dev Modifier that requires the message sender
     * to be whitelisted and not blacklisted
     */
    modifier onlyHasAccess() {
        require(hasAccess(msg.sender), "no access");
        _;
    }

    /**
     * @dev Modifier that requires given address
     * to be whitelisted
     * @param account address to be checked
     */
    modifier requireWhitelisted(address account) {
        require(isWhitelisted(account), "no access");
        _;
    }

    /**
     * @dev Modifier that requires message sender
     * to be whitelisted
     */
    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "no access");
        _;
    }

    /**
     * @dev Modifier that requires given address
     * to not be blacklisted
     * @param account address to be checked
     */
    modifier requireNotBlacklisted(address account) {
        require(isNotBlacklisted(account), "no access");
        _;
    }

    /**
     * @dev Modifier that requires message sender
     * to not be blacklisted
     */
    modifier onlyNotBlacklisted() {
        require(isNotBlacklisted(msg.sender), "no access");
        _;
    }

    /**
     * @dev Returns whether account has access.
     * If whitelist is enabled a whitelist check is also made,
     * otherwise it only checks for blacklisting.
     * @param account Address to be checked
     * @return true if address has access or is not blacklisted when whitelist
     * is disabled
     */
    function hasAccess(address account) public view returns (bool) {
        if (whitelistEnabled) {
            return accesslist.hasAccess(account);
        } else {
            return isNotBlacklisted(account);
        }
    }

    /**
     * @dev Returns whether account is whitelisted
     * @param account Address to be checked
     * @return true if address is whitelisted
     */
    function isWhitelisted(address account) public view returns (bool) {
        return accesslist.isWhitelisted(account);
    }

    /**
     * @dev Returns whether account is not blacklisted
     * @param account Address to be checked
     * @return true if address is not blacklisted
     */
    function isNotBlacklisted(address account) public view returns (bool) {
        return !accesslist.isBlacklisted(account);
    }
}
