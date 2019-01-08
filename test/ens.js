/* global artifacts */

const ENSRegistry = artifacts.require('ENSRegistry.sol');
const PublicResolver = artifacts.require('PublicResolver.sol');
const namehash = require('eth-ens-namehash');

exports.setENS = async function (name, parentNode, address, owner) {
  const hashedname = namehash.hash(`${name}.${parentNode}`);
  const ens = await ENSRegistry.deployed();
  const resolver = await PublicResolver.deployed();

  await ens.setSubnodeOwner(namehash.hash(parentNode), web3.sha3(name), owner, { from: owner });
  await ens.setResolver(hashedname, PublicResolver.address, { from: owner });

  await resolver.setAddr(hashedname, address, { from: owner });
}
