/* global artifacts */

const Accesslist = artifacts.require('Accesslist');
const TokenManager = artifacts.require('TokenManager');
const EToken = artifacts.require('EToken');

const { ZERO_ADDRESS } = require('../test/utils.js');

module.exports = function (deployer, _network, accounts) {
  if (deployer.network === 'development' ||
      deployer.network === 'develop' ||
      deployer.network === 'ropsten') {
    deployer.then(() => setupAccounts(accounts));
  }
};

async function setupAccounts ([owner, ..._]) {
  /*
    The purpose of this is to automatically setup the test environment accounts.
    DO NOT use in production yet.
  */

  // FIXME: Use some real address here
  const mintTargetAccount = 0xd00f;

  // Setup whitelists
  const accesslistContract = await Accesslist.deployed();

  // Setup tokens
  const tokenManagerContract = await TokenManager.deployed();

  const tokenDetails = [
    {
      name: 'eToro Israel Shekel',
      symbol: 'eILS',
      decimals: 2,
      whitelistEnabled: true
    },
    {
      name: 'eToro Danish krone',
      symbol: 'eDKK',
      decimals: 2,
      whitelistEnabled: false
    }
  ];

  await Promise.all(
    tokenDetails.map(async (td) => {
      const token = await EToken.new(
        td.name, td.symbol, td.decimals,
        accesslistContract.address, td.whitelistEnabled,
        ZERO_ADDRESS,
        mintTargetAccount, ZERO_ADDRESS, true,
        { from: owner });

      await tokenManagerContract.addToken(td.name, token.address);
      return token;
    }));
}
