/* global artifacts */

'use strict';

const Ownable = artifacts.require('Ownable.sol');

const argv = require('optimist')
  .usage('Usage: --network [name] --owner [address] --newOwner [address] --ownableContracts [multiple addresses]')
  .describe('network', 'truffle network configuration name')
  .string(['owner', 'newOwner', 'ownableContracts'])
  .demand(['owner', 'newOwner', 'ownableContracts'])
  .argv;

const transferOwnershipHelper = require('./transferOwnershipHelper');

async function transferOwnershipWrapper () {
  const ownableContracts = argv.ownableContracts
    .split(' ')
    .map(addr => Ownable.at(addr));

  await transferOwnershipHelper(argv.owner, argv.newOwner, ownableContracts);
}

module.exports = (callback, test) => {
  transferOwnershipWrapper().then(
    () => callback(),
    (err) => callback(err)
  );
};
