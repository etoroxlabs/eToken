pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./token/ERC20/ExternalERC20Storage.sol";
import "./token/IEToroToken.sol";

/**
   @title The Token Manager contract
   @dev Contract that keeps track of and adds new tokens to list
*/
contract TokenManager is Ownable {

    /**
       @dev A TokenEntry defines a relation between an EToroToken instance and the
       index of the names list containing the name of the token.
     */
    struct TokenEntry {
        bool exists;
        uint index;
        IEToroToken token;
    }

    mapping (bytes32 => TokenEntry) private tokens;
    bytes32[] private names;

    event TokenAdded(bytes32 _name);
    event TokenDeleted(bytes32 _name);
    event TokenUpgraded(bytes32 _name);

    /**
       @dev Require that the token _name exists
       @param _name Name of token that is looked for
    */
    modifier tokenExists(bytes32 _name) {
        require(_tokenExists(_name), "Token does not exist");
        _;
    }

    /**
       @dev Require that the token _name does not exist
       @param _name Name of token that is looked for 
    */
    modifier tokenNotExists(bytes32 _name) {
        require(!(_tokenExists(_name)), "Token already exist");
        _;
    }

    /**
       @dev Require that the token _iEToroToken is not null
       @param _iEToroToken Token that is checked for
    */
    modifier notNullToken(IEToroToken _iEToroToken) {
        require(_iEToroToken != IEToroToken(0), "Supplied token is null");
        _;
    }

    /**
       @dev Adds a token to the tokenmanager
       @param _name Name of the token to be added
       @param _iEToroToken Token to be added
    */
    function addToken(bytes32 _name, IEToroToken _iEToroToken)
        public
        onlyOwner
        tokenNotExists(_name)
        notNullToken(_iEToroToken)
    {
        tokens[_name] = TokenEntry({
            index: names.length,
            token: _iEToroToken,
            exists: true
        });
        names.push(_name);
        emit TokenAdded(_name);
    }

    /**
       @dev Deletes a token.
       @param _name Name of token to be deleted
    */
    function deleteToken(bytes32 _name)
        public
        onlyOwner
        tokenExists(_name)
    {
        delete names[tokens[_name].index];
        delete tokens[_name].token;
        delete tokens[_name];
        emit TokenDeleted(_name);
    }

    /**
       @dev Upgrades a token
       @param _name Name of token to be upgraded
       @param _iEToroToken Upgraded version of token
    */
    function upgradeToken(bytes32 _name, IEToroToken _iEToroToken)
        public
        onlyOwner
        tokenExists(_name)
        notNullToken(_iEToroToken)
    {
        tokens[_name].token = _iEToroToken;
        emit TokenUpgraded(_name);
    }

    /**
       @dev Returns a token of specified name
       @param _name Name of token to be returned
    */
    function getToken (bytes32 _name)
        public
        tokenExists(_name)
        view
        returns (IEToroToken)
    {
        return tokens[_name].token;
    }

    /**
       @dev Returns list of tokens
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
       @dev Checks whether a token of specified name exists exists
       in list of tokens
       @param _name Name of token
     */
    function _tokenExists (bytes32 _name)
        private
        view
        returns (bool)
    {
        return tokens[_name].exists;
    }

}
