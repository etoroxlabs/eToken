pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./roles/WhitelistedRole.sol";
import "./roles/AdministratorRole.sol";

contract EToroRole is Ownable, WhitelistedRole, AdministratorRole {

    bool public whitelistEnabled = true;

    WhitelistedRole private whitelistedRole;
    AdministratorRole private administratorRole;

    modifier onlyWhitelisted() {
        checkWhitelisted(msg.sender);
        _;
    }

    modifier onlyAdmin() {
        administratorRole.isAdmin(msg.sender);
        _;
    }

    function checkWhitelisted(address user) public view {
        if (whitelistEnabled && user != owner) { // owner is also auto whitelisted
            whitelistedRole.isWhitelisted(user);
        }
    }

    function enableWhitelist(bool value) public onlyOwner {
        whitelistEnabled = value;
    }

    function addAdmin(address user) public onlyOwner {
        administratorRole.addAdmin(user);
    }

    function removeAdmin(address user) public onlyOwner {
        administratorRole.removeAdmin(user);
    }

    function renounceAdmin() public onlyAdmin {
        administratorRole.renounceAdmin();
    }

    function addToWhitelist(address user) public onlyAdmin { 
        whitelistedRole.addWhitelisted(user); 
    } 

    function removeFromWhitelist(address user) public onlyAdmin {
        whitelistedRole.removeWhitelisted(user);
    }

}
