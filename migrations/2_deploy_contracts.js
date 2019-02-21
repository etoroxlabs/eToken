/* global artifacts, web3 */

let Accesslist = artifacts.require('Accesslist');
let TokenManager = artifacts.require('TokenManager');

const ENS = artifacts.require('ENSRegistry');
const PublicResolver = artifacts.require('PublicResolver');
const ReverseRegistrar = artifacts.require('ReverseRegistrar');
const namehash = require('eth-ens-namehash');

module.exports = function (deployer, _network, accounts) {
  const owner = accounts[0];

  // I guess?? This is elided from the tutorial, FFS
  const tld = 'eth';

  // Deploy eTokenize contracts
  deployer.deploy(Accesslist);
  deployer.deploy(TokenManager);

  // Deploy local ENS when running on dev network
  if (deployer.network === 'development' ||
        deployer.network === 'develop' ||
        deployer.network === 'ropsten') {
    deployer.deploy(ENS)
      .then(() => {
        return deployer.deploy(
          PublicResolver,
          ENS.address);
      })
      .then(() => {
        return deployer.deploy(
          ReverseRegistrar,
          ENS.address,
          PublicResolver.address);
      })
      .then(() => {
        return ENS.at(ENS.address)
          .setSubnodeOwner(
            0,
            web3.sha3(tld),
            owner, { from: owner });
      })
      .then(() => {
        return ENS.at(ENS.address)
          .setSubnodeOwner(
            0,
            web3.sha3('reverse'),
            owner, { from: owner });
      })
      .then(() => {
        return ENS.at(ENS.address)
          .setSubnodeOwner(
            namehash.hash('reverse'),
            web3.sha3('addr'),
            ReverseRegistrar.address, { from: owner });
      });
  }
};
