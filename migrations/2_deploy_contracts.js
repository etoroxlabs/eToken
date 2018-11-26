let EToroRole = artifacts.require('EToroRole');
//let EToroToken = artifacts.require('EToroToken');
let TokenManager = artifacts.require('TokenManager');

module.exports = function(deployer) {
    deployer.deploy(EToroRole);
    //deployer.deploy(EToroToken);
    deployer.deploy(TokenManager);
}
