/**
 * MIT License
 *
 * Copyright (c) 2019 eToroX Labs
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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

const disableToken = require('./disableToken');

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

  await disableToken(DisableToken, token, tokenOwner);
}

module.exports = (callback, test) => {
  disableTokenWrapper().then(
    () => callback(),
    (err) => callback(err)
  );
};
