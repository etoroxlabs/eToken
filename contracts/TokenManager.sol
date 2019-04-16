/**
 * MIT License
 *
 * Copyright (c) 2019 eToroX Labs
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./token/IEToken.sol";

/**
 * @title The Token Manager contract
 * @dev Contract that keeps track of and adds new tokens to list
 */
contract TokenManager is Ownable {

    /**
     * @dev A TokenEntry defines a relation between an EToken instance and the
     * index of the names list containing the name of the token.
     */
    struct TokenEntry {
        bool exists;
        uint index;
        IEToken token;
    }

    mapping (bytes32 => TokenEntry) private tokens;
    bytes32[] private names;

    event TokenAdded(bytes32 indexed name, IEToken indexed addr);
    event TokenDeleted(bytes32 indexed name, IEToken indexed addr);
    event TokenUpgraded(bytes32 indexed name,
                        IEToken indexed from,
                        IEToken indexed to);

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
     * @dev Require that the token _iEToken is not null
     * @param _iEToken Token that is checked for
     */
    modifier notNullToken(IEToken _iEToken) {
        require(_iEToken != IEToken(0), "Supplied token is null");
        _;
    }

    /**
     * @dev Adds a token to the tokenmanager
     * @param _name Name of the token to be added
     * @param _iEToken Token to be added
     */
    function addToken(bytes32 _name, IEToken _iEToken)
        public
        onlyOwner
        tokenNotExists(_name)
        notNullToken(_iEToken)
    {
        tokens[_name] = TokenEntry({
            index: names.length,
            token: _iEToken,
            exists: true
        });
        names.push(_name);
        emit TokenAdded(_name, _iEToken);
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
        IEToken prev = tokens[_name].token;
        delete names[tokens[_name].index];
        delete tokens[_name].token;
        delete tokens[_name];
        emit TokenDeleted(_name, prev);
    }

    /**
     * @dev Upgrades a token
     * @param _name Name of token to be upgraded
     * @param _iEToken Upgraded version of token
     */
    function upgradeToken(bytes32 _name, IEToken _iEToken)
        public
        onlyOwner
        tokenExists(_name)
        notNullToken(_iEToken)
    {
        IEToken prev = tokens[_name].token;
        tokens[_name].token = _iEToken;
        emit TokenUpgraded(_name, prev, _iEToken);
    }

    /**
     * @dev Finds a token of the specified name
     * @param _name Name of the token to be returned
     * @return The token of the given name
     */
    function getToken (bytes32 _name)
        public
        tokenExists(_name)
        view
        returns (IEToken)
    {
        return tokens[_name].token;
    }

    /**
     * @dev Gets all token names
     * @return A list of names
     */
    function getTokens ()
        public
        view
        returns (bytes32[])
    {
        return names;
    }

    /**
     * @dev Checks whether a token of specified name exists exists
     * in list of tokens
     * @param _name Name of token
     * @return true if a token of the given name exists
     */
    function _tokenExists (bytes32 _name)
        private
        view
        returns (bool)
    {
        return tokens[_name].exists;
    }

}
