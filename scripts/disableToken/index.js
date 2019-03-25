/* global artifacts */

'use strict';

const DisableToken = artifacts.require('DisableToken.sol');
const EToken = artifacts.require('EToken.sol');

const readlineSync = require('readline-sync');

const argv = require('optimist')
  .usage('Usage: --network [name] --token [address] --tokenOwner [address]')
  .describe('network', 'truffle network configuration name')
  .string(['token', 'tokenOwner'])
  .demand(['token', 'tokenOwner'])
  .argv;

const disableTokenHelper = require('./disableTokenHelper');

async function disableTokenWrapper () {
  const token = EToken.at(argv.token);
  const tokenOwner = argv.tokenOwner.toLowerCase();

  if ((await token.owner()) !== tokenOwner) {
    throw Error('tokenOwner is not correct');
  }

  const answer = readlineSync.question(
    'WARNING: This will permentaly disable your token. Enter \'I understand\' to proceed...\n');

  if (answer !== 'I understand') {
    throw Error('You do not understand');
  }

  await disableTokenHelper(DisableToken, token, tokenOwner);
}

module.exports = (callback, test) => {
  disableTokenWrapper().then(
    () => callback(),
    (err) => callback(err)
  );
};
