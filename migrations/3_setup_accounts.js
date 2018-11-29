
const Whitelist = artifacts.require("Whitelist");
const TokenManager = artifacts.require("TokenManager");

module.exports = async function(deployer, _network, accounts) {

  /*
    The purpose of this is to automatically setup the test environment accounts.
    DO NOT use in production yet.
  */

  if (deployer.network == 'development' ||
      deployer.network == 'develop') {

    const owner = accounts[0];
    const whitelistAdmin = accounts[1];
    const whitelisted = accounts[2];

    // Setup whitelists
    const whitelistContract = await Whitelist.deployed();
    
    await whitelistContract.addWhitelistAdmin(whitelistAdmin, { from: owner });
    await whitelistContract.addWhitelisted(whitelisted, { from: whitelistAdmin });

    // Setup tokens
    const tokenManagerContract = await TokenManager.deployed();

    await tokenManagerContract.newToken("eToro US Dollar", "eUSD", 4, whitelistContract.address, { from: owner });
    await tokenManagerContract.newToken("eToro Australian Dollar", "eAUD", 4, whitelistContract.address, { from: owner });
  }
}