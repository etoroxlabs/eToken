pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/rbac/RBAC.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./KillSwitch.sol";

contract EToroRole is RBAC, Ownable, KillSwitch {
    string public constant ROLE_WHITELISTED = "whitelisted";
    string public constant ROLE_ADMIN = "admin";

    bool public isWhitelisted = true;

    modifier onlyWhitelisted() {
        checkWhitelisted(msg.sender);
        _;
    }
    
    modifier onlyAdmin() {
        checkRole(msg.sender, ROLE_ADMIN);
        _;
    }

    function checkWhitelisted(address user) public view {
        if (isWhitelisted && user != owner) { // owner is also auto whitelisted 
            checkRole(user, ROLE_WHITELISTED);
        }
    }

    function enableWhitelist(bool value) public onlyOwner {
        isWhitelisted = value;
    }

    function addAdmin(address user) public onlyOwner {
        addRole(user, ROLE_ADMIN);
    }

    function removeAdmin(address user) public onlyOwner {
        removeRole(user, ROLE_ADMIN);
    }

    function addToWhitelist(address user) public onlyAdmin {
        addRole(user, ROLE_WHITELISTED);
    }

    function removeFromWhitelist(address user) public onlyAdmin {
        removeRole(user, ROLE_WHITELISTED);
    }

}