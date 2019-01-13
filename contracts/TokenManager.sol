pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./token/ITokenX.sol";

/**
 * @title The Token Manager contract
 * @dev Contract that keeps track of and adds new tokens to list
 */
contract TokenManager is Ownable {

    /**
     * @dev A TokenEntry defines a relation between a TokenX instance and the
     * index of the names list containing the name of the token.
     */
    struct TokenEntry {
        bool exists;
        uint index;
        ITokenX token;
    }

    mapping (bytes32 => TokenEntry) private tokens;
    bytes32[] private names;

    event TokenAdded(bytes32 indexed name, ITokenX indexed addr);
    event TokenDeleted(bytes32 indexed name, ITokenX indexed addr);
    event TokenUpgraded(bytes32 indexed name,
                        ITokenX indexed from,
                        ITokenX indexed to);

    /**
     * @dev Require that the token _name exists
     * @param _name Name of token that is looked for
     */
    modifier tokenExists(bytes32 _name) {
        require(_tokenExists(_name), "Token does not exist");
        _;
    }

    /**
     * @dev Require that the token _name does not exist
     * @param _name Name of token that is looked for
     */
    modifier tokenNotExists(bytes32 _name) {
        require(!(_tokenExists(_name)), "Token already exist");
        _;
    }

    /**
     * @dev Require that the token _iTokenX is not null
     * @param _iTokenX Token that is checked for
     */
    modifier notNullToken(ITokenX _iTokenX) {
        require(_iTokenX != ITokenX(0), "Supplied token is null");
        _;
    }

    /**
     * @dev Adds a token to the tokenmanager
     * @param _name Name of the token to be added
     * @param _iTokenX Token to be added
     */
    function addToken(bytes32 _name, ITokenX _iTokenX)
        public
        onlyOwner
        tokenNotExists(_name)
        notNullToken(_iTokenX)
    {
        tokens[_name] = TokenEntry({
            index: names.length,
            token: _iTokenX,
            exists: true
        });
        names.push(_name);
        emit TokenAdded(_name, _iTokenX);
    }

    /**
     * @dev Deletes a token.
     * @param _name Name of token to be deleted
     */
    function deleteToken(bytes32 _name)
        public
        onlyOwner
        tokenExists(_name)
    {
        ITokenX prev = tokens[_name].token;
        delete names[tokens[_name].index];
        delete tokens[_name].token;
        delete tokens[_name];
        emit TokenDeleted(_name, prev);
    }

    /**
     * @dev Upgrades a token
     * @param _name Name of token to be upgraded
     * @param _iTokenX Upgraded version of token
     */
    function upgradeToken(bytes32 _name, ITokenX _iTokenX)
        public
        onlyOwner
        tokenExists(_name)
        notNullToken(_iTokenX)
    {
        ITokenX prev = tokens[_name].token;
        tokens[_name].token = _iTokenX;
        emit TokenUpgraded(_name, prev, _iTokenX);
    }

    /**
     * @dev Returns a token of specified name
     * @param _name Name of token to be returned
     */
    function getToken (bytes32 _name)
        public
        tokenExists(_name)
        view
        returns (ITokenX)
    {
        return tokens[_name].token;
    }

    /**
     * @dev Returns list of tokens
     */
    function getTokens ()
        public
        view
        returns (bytes32[])
    {
        // TODO: Maybe filter out 0 entries (deleted names) from the list?
        return names;
    }

    /**
     * @dev Checks whether a token of specified name exists exists
     * in list of tokens
     * @param _name Name of token
     */
    function _tokenExists (bytes32 _name)
        private
        view
        returns (bool)
    {
        return tokens[_name].exists;
    }

}
