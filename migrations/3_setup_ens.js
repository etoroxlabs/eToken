
const Whitelist = artifacts.require("Whitelist");
const TokenManager = artifacts.require("TokenManager");
const ENSRegistry = artifacts.require('ENSRegistry.sol');
const PublicResolver = artifacts.require('PublicResolver.sol');
const namehash = require('eth-ens-namehash');

async function setENS(name, parentNode, address, owner) {
  const hashedname = namehash.hash(`${name}.${parentNode}`);
  const ens = await ENSRegistry.deployed();
  const resolver = await PublicResolver.deployed();

  await ens.setSubnodeOwner(namehash.hash(parentNode), web3.sha3(name), owner, {from: owner});
  await ens.setResolver(hashedname, PublicResolver.address, {from: owner});
  
  await resolver.setAddr(hashedname, address, {from: owner});
}

async function getENSaddr(name) {
  const hashedname = namehash.hash(name);
  const resolver = await PublicResolver.deployed();
  const res = await resolver.addr.call(hashedname);
  
  return res;
}


module.exports = (deployer, network, accounts) =>{
  const owner = accounts[0];
  const dummyaddress = '0x5aeda56215b167893e80b4fe645ba6d5bab767de'; //used accounts[9] as a placeholder for etokenize.eth addresss
  const tld = 'eth';
  const etokenize_name = 'etokenize'
  const etokenize_tld_name = etokenize_name + '.' + tld;
  const whitelist_name = 'whitelist';
  const tokenmanager_name = 'manager';

  if (deployer.network == 'development' ||
      deployer.network == 'develop') {
      deployer.then(async () => {
      
      await setENS(etokenize_name, tld, dummyaddress, owner);
      await setENS(whitelist_name, etokenize_tld_name, Whitelist.address, owner);
      await setENS(tokenmanager_name, etokenize_tld_name, TokenManager.address, owner);
    });
  }
}