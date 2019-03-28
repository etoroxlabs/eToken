/* global artifacts */

'use strict';

const EToken = artifacts.require('EToken.sol');
const Ownable = artifacts.require('Ownable.sol');

const argv = require('optimist')
  .usage('Usage: --network [name] --owner [address] --newOwner [address] --ownableContracts [multiple addresses]')
  .describe('network', 'truffle network configuration name')
  .string(['owner', 'newOwner', 'ownableContracts'])
  .demand(['owner', 'newOwner', 'ownableContracts'])
  .argv;

const transferTokenOwnershipHelper = require('./transferTokenOwnershipHelper');

async function transferOwnershipWrapper () {
  const ownableContracts = argv.ownableContracts
    .split(' ')
    .map(addr => EToken.at(addr));

  await transferTokenOwnershipHelper(Ownable.at, argv.owner, argv.newOwner, ownableContracts);
}

module.exports = (callback, test) => {
  transferOwnershipWrapper().then(
    () => callback(),
    (err) => callback(err)
  );
};
