/* global artifacts, web3 */

const Accesslist = artifacts.require('Accesslist');
const TokenManager = artifacts.require('TokenManager');
const ENSRegistry = artifacts.require('ENSRegistry.sol');
const PublicResolver = artifacts.require('PublicResolver.sol');
const namehash = require('eth-ens-namehash');

async function setENS (name, parentNode, address, owner) {
  const hashedname = namehash.hash(`${name}.${parentNode}`);
  const ens = await ENSRegistry.deployed();
  const resolver = await PublicResolver.deployed();

  await ens.setSubnodeOwner(namehash.hash(parentNode), web3.sha3(name), owner, { from: owner });
  await ens.setResolver(hashedname, PublicResolver.address, { from: owner });

  await resolver.setAddr(hashedname, address, { from: owner });
}

module.exports = (deployer, network, accounts) => {
  const owner = accounts[0];
  const dummyaddress = accounts[0];
  const tld = 'eth';
  const etokenizeName = 'etokenize';
  const etokenizeTldName = etokenizeName + '.' + tld;
  const accesslistName = 'accesslist';
  const tokenManagerName = 'tokenmanager';

  if (deployer.network === 'development' ||
      deployer.network === 'develop' ||
      deployer.network === 'ropsten') {
    deployer.then(async () => {
      await setENS(etokenizeName, tld, dummyaddress, owner);
      await setENS(accesslistName, etokenizeTldName, Accesslist.address, owner);
      await setENS(tokenManagerName, etokenizeTldName, TokenManager.address, owner);
    });
  }
};
