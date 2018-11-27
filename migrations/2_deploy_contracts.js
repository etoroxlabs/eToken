let Whitelist = artifacts.require('Whitelist');
let TokenManager = artifacts.require('TokenManager');

const ENS = artifacts.require('@ensdomains/ens/contracts/ENSRegistry.sol');
const PublicResolver = artifacts.require('@ensdomains/ens/contracts/PublicResolver.sol');
const ReverseRegistrar = artifacts.require('@ensdomains/ens/contracts/ReverseRegistrar.sol');
const namehash = require('eth-ens-namehash');

module.exports = function(deployer) {
    if (deployer.network == 'development'){
        deployer.deploy(Whitelist)
        .then (() => {
            deployer.deploy(TokenManager, Whitelist.address)
            .then(() => {
                return deployer.deploy(ENS)
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
                        owner, {from: owner});
                })
                .then(() => {
                    return ENS.at(ENS.address)
                    .setSubnodeOwner(0,
                        web3.sha3('reverse'),
                        owner,{from: owner});
                })
                .then(() => {
                    return ENS.at(ENS.address)
                    .setSubnodeOwner(
                        namehash.hash('reverse'),
                        web3.sha3('addr'),
                        ReverseRegistrar.address, {from: owner});
                })
            })
        })
    }
}
