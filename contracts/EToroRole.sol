pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./roles/WhitelistedRole.sol";
import "./roles/AdministratorRole.sol";

contract EToroRole is Ownable, WhitelistedRole, AdministratorRole {
    string public constant ROLE_WHITELISTED = "whitelisted";
    string public constant ROLE_ADMIN = "admin";

    bool public isWhitelisted = true;

    WhitelistedRole private whitelistedrole;
    AdministratorRole private administratorrole;

    modifier onlyWhitelisted() {
        checkWhitelisted(msg.sender);
        _;
    }

    modifier onlyAdmin() {
        administratorrole.isAdmin(msg.sender);
        _;
    }

    function checkWhitelisted(address user) public view {
        if (isWhitelisted && user != owner) { // owner is also auto whitelisted
            whitelistedrole.isWhitelisted(user);
        }
    }

    function enableWhitelist(bool value) public onlyOwner {
        isWhitelisted = value;
    }

    function addAdmin(address user) public onlyOwner {
        administratorrole.addAdmin(user);
    }

    function removeAdmin(address user) public onlyOwner {
        administratorrole.removeAdmin(user);
    }

    function renounceAdmin(address user) public onlyAdmin {
        administratorrole.renounceAdmin();
    }

    function addToWhitelist(address user) public onlyAdmin { 
        whitelistedrole.addWhitelisted(user); 
    } 

    function removeFromWhitelist(address user) public onlyAdmin {
        whitelistedrole.removeWhitelisted(user);
    }

}
