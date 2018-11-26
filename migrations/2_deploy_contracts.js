let Whitelist = artifacts.require('Whitelist');
let TokenManager = artifacts.require('TokenManager');

module.exports = function(deployer) {
    deployer.deploy(Whitelist);
    deployer.deploy(TokenManager);
}
