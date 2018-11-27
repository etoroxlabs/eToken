
const Whitelist = artifacts.require("Whitelist");
const TokenManager = artifacts.require("TokenManager");

module.exports = function(callback) {

  /*
    The purpose of this is to automatically setup the test environment accounts.
    DO NOT use in production yet.
  */

  const owner = web3.eth.accounts[0];
  const whitelistAdmin = web3.eth.accounts[1];
  const whitelisted = web3.eth.accounts[2];

  const exec = async () => {

    // Setup whitelists
    const whitelistContract = await Whitelist.deployed();
    
    await whitelistContract.addWhitelistAdmin(whitelistAdmin, { from: owner });
    await whitelistContract.addWhitelisted(whitelisted, { from: whitelistAdmin });

    // Setup tokens
    const tokenManagerContract = await TokenManager.deployed();

    await tokenManagerContract.newToken("eToro US Dollar", "eUSD", 4, whitelistContract.address, { from: owner });
    await tokenManagerContract.newToken("eToro Australian Dollar", "eAUD", 4, whitelistContract.address, { from: owner });
  }

  exec().then(
    () => callback(),
    (reason) => callback(reason)
  )
}