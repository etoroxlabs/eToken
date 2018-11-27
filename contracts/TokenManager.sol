pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./EToroToken.sol";
import "./lib/StringUtils.sol";

contract TokenManager is Ownable {

    /**
       A TokenEntry defines a relation between an EToroToken instance and the
       index of the names list containing the name of the token.
     */
    struct TokenEntry {
        bool exists;
        uint index;
        EToroToken token;
    }

    mapping (bytes32 => TokenEntry) private tokens;
    bytes32[] private names;

    event TokenCreated(bytes32 _name);
    event TokenDeleted(bytes32 _name);

    /**
       Returns true if the token specified in _name exists
     */
    function _tokenExists (bytes32 _name)
        private
        view
        returns (bool)
    {
        return tokens[_name].exists;
    }


    /**
       Require that the token _name exists
    */
    modifier tokenExists (bytes32 _name) {
        require(_tokenExists(_name));
        _;
    }


    /**
       Require that the token _name does not exist
    */
    modifier tokenNotExists (bytes32 _name) {
        require(!(_tokenExists(_name)));
        _;
    }


    /**
       Creates a new token
    */
    function newToken (bytes32 _name, string _symbol, uint8 _decimals, address eToroRole)
        public
        onlyOwner
        tokenNotExists(_name)
    {
        // TODO: I really want to get rid of this hacky type conversion
        // It's only here because we can't return an array of strings from the
        // getTokens functions, so we store token names as bytes32.
        // Solc suggests that enabling experimental ABIEncoderV2 will allow us
        // to return an array of strings thereby making this hack redundant.
        // Consider the tradeoffs related to this.
        //
        // Alternatively, we could require that the client (or a server)
        // maintains client names separately and limit this contract to only
        // returning a hashed list of the contract names.
        string memory nameStr = StringUtils.bytes32ToString(_name);

        EToroToken tok = new EToroToken(nameStr, _symbol, _decimals, msg.sender, eToroRole);
        tokens[_name] = TokenEntry({index: names.length, token: tok, exists: true});
        names.push(_name);
        emit TokenCreated(_name);
    }


    /**
       Deletes a token.
    */
    function deleteToken (bytes32 _name)
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
       Returns the token _name
    */
    function getToken (bytes32 _name)
        public
        tokenExists(_name)
        view
        returns (EToroToken)
    {
        return tokens[_name].token;
    }


    /**
       Returns list of tokens
    */
    function getTokens ()
        public
        view
        returns (bytes32[])
    {
        // TODO: Maybe filter out 0 entries (deleted names) from the list?
        return names;
    }
}
