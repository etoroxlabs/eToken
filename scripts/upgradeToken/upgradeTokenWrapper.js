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

const TokenManager = artifacts.require('TokenManager.sol');
const EToken = artifacts.require('./EToken.sol');

const argv = require('optimist')
  .usage('Usage: --network [name] --tokenManager [address] --oldToken [address] --newToken [address] --tokenManagerOwner [address] --oldTokenOwner [address]')
  .describe('network', 'truffle network configuration name')
  .demand(['tokenManager', 'oldToken', 'newToken', 'tokenManagerOwner', 'oldTokenOwner'])
  .argv;

const upgradeToken = require('./upgradeToken');

async function upgradeTokenWrapper () {
  const tokenManager = TokenManager.at(argv.tokenManager);
  const oldToken = EToken.at(argv.oldToken);
  const newToken = EToken.at(argv.newToken);

  const tokenManagerOwner = argv.tokenManagerOwner;
  const oldTokenOwner = argv.oldTokenOwner;

  if ((await tokenManager.owner()) !== tokenManagerOwner) {
    throw Error('tokenManagerOwner is not correct');
  }

  if ((await oldToken.owner()) !== oldTokenOwner) {
    throw Error('oldTokenOwner is not correct');
  }

  await newToken.owner();

  await upgradeToken(tokenManager, oldToken, newToken, tokenManagerOwner, oldTokenOwner);
}

module.exports = (callback, test) => {
  upgradeTokenWrapper().then(
    () => callback(),
    (err) => callback(err)
  );
};
