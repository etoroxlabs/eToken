/* global artifacts */

const Accesslist = artifacts.require('Accesslist');
const TokenManager = artifacts.require('TokenManager');
const EToken = artifacts.require('EToken');

const { ZERO_ADDRESS } = require('../test/utils.js');

module.exports = function (deployer, _network, accounts) {
  if (deployer.network === 'development' ||
      deployer.network === 'develop' ||
      deployer.network === 'ropsten' ||
      deployer.network === 'mainnet') {
    deployer.then(() => setupAccounts(accounts));
  }
};

async function setupAccounts ([owner, ..._]) {
  const mintTargetAccount = owner;

  // Setup whitelists
  const accesslistContract = await Accesslist.deployed();

  // Setup tokens
  const tokenManagerContract = await TokenManager.deployed();

  const tokenDetails = [
    {
      name: 'Etoro United States Dollar',
      symbol: 'USDX',
      decimals: 18,
      whitelistEnabled: true
    },
    {
      name: 'Etoro Euro',
      symbol: 'EURX',
      decimals: 18,
      whitelistEnabled: true
    },
    {
      name: 'Etoro Pound sterling',
      symbol: 'GBPX',
      decimals: 18,
      whitelistEnabled: true
    },
    {
      name: 'Etoro Australian Dollar',
      symbol: 'AUDX',
      decimals: 18,
      whitelistEnabled: true
    },
    {
      name: 'Etoro New Zealand Dollar',
      symbol: 'NZDX',
      decimals: 18,
      whitelistEnabled: true
    },
    {
      name: 'Etoro Japanese Yen',
      symbol: 'JPYX',
      decimals: 18,
      whitelistEnabled: true
    },
    {
      name: 'Etoro Russian Ruble',
      symbol: 'RUBX',
      decimals: 18,
      whitelistEnabled: true
    },
    {
      name: 'Etoro Chinese Yuan',
      symbol: 'CNYX',
      decimals: 18,
      whitelistEnabled: true
    },
    {
      name: 'Etoro Swiss Franc',
      symbol: 'CHFX',
      decimals: 18,
      whitelistEnabled: true
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
