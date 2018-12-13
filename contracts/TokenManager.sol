pragma solidity ^0.4.24;

/* solium-disable max-len */
import "etokenize-openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "etokenize-openzeppelin-solidity/contracts/token/ERC20/external/ExternalERC20Storage.sol";
import "./token/IEToroToken.sol";
/* solium-enable max-len */

contract TokenManager is Ownable {

    /**
       A TokenEntry defines a relation between an EToroToken instance and the
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
       Require that the token _name exists
    */
    modifier tokenExists(bytes32 _name) {
        require(_tokenExists(_name), "Token does not exist");
        _;
    }

    /**
       Require that the token _name does not exist
    */
    modifier tokenNotExists(bytes32 _name) {
        require(!(_tokenExists(_name)), "Token already exist");
        _;
    }

    modifier notNullToken(IEToroToken _iEToroToken) {
        require(_iEToroToken != IEToroToken(0), "Supplied token is null");
        _;
    }

    /**
       Adds a token to the manager
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
       Deletes a token.
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
       Upgrades a token
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
       Returns the token _name
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

}
