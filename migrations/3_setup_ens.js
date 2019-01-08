/* global artifacts, web3 */

const Accesslist = artifacts.require('Accesslist');
const TokenManager = artifacts.require('TokenManager');

const ens = require('../test/ens.js');

module.exports = (deployer, network, accounts) => {
  const owner = accounts[0];
  const dummyaddress = '0x5aeda56215b167893e80b4fe645ba6d5bab767de'; // used accounts[9] as a placeholder for etokenize.eth addresss
  const tld = 'eth';
  const etokenizeName = 'etokenize';
  const etokenizeTldName = etokenizeName + '.' + tld;
  const accesslistName = 'accesslist';
  const tokenManagerName = 'manager';

  if (deployer.network === 'development' ||
      deployer.network === 'develop') {
    deployer.then(async () => {
      await ens.setENS(etokenizeName, tld, dummyaddress, owner);
      await ens.setENS(accesslistName, etokenizeTldName, Accesslist.address, owner);
      await ens.setENS(tokenManagerName, etokenizeTldName, TokenManager.address, owner);
    });
  }
};
