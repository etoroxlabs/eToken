
const Whitelist = artifacts.require("Whitelist");

module.exports = function(callback) {

  /*
    The purpose of this is to automatically setup the test environment accounts.
    DO NOT use in production yet.
  */

  const owner = web3.eth.accounts[0];
  const whitelistAdmin = web3.eth.accounts[1];
  const whitelisted = web3.eth.accounts[2];

  const exec = async () => {
    const contract = await Whitelist.deployed();
    
    await contract.addWhitelistAdmin(whitelistAdmin, { from: owner });
    await contract.addWhitelisted(whitelisted, { from: whitelistAdmin });
  }

  exec().then(
    () => callback(),
    (reason) => callback(reason)
  )
}