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

/* global artifacts, web3, contract */
/* eslint-env mocha */

'use strict';

const util = require('./../utils.js');

const Storage = artifacts.require('Storage');
const ETokenGuardedMock = artifacts.require('ETokenGuardedMock');
const UpgradeSupportE = require('./UpgradeSupport.events.js');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('UpgradeSupport', function ([owner, someAddress, ...rest]) {
  describe('finalizeUpgrade', function () {
    it('reverts when no upgradeFrom contract is set', async function () {
      const token = await ETokenGuardedMock.new(0, 0, true, { from: owner });

      await util.assertRevertsReason(token.finalizeUpgrade({ from: owner }),
                                     'Must have a contract to upgrade from');
    });

    it('reverts when wrong contract finalizes upgrade', async function () {
      const token = await ETokenGuardedMock.new(0xf00, 0xf00, false, { from: owner });

      await util.assertRevertsReason(token.finalizeUpgrade({ from: someAddress }),
                                     'Proxy is the only allowed caller');
    });

    it('emits UpgradeFinalized event', async function () {
      const token = await ETokenGuardedMock.new(0xf00, owner, false, { from: owner });
      const tokenE = UpgradeSupportE.wrap(token);

      await tokenE.finalizeUpgrade(owner, { from: owner });
    });

    it('emits Upgrdaed event', async function () {
      const token = await ETokenGuardedMock.new(0, 0, true, { from: owner });
      const storage = Storage.at(await token.getExternalStorage());
      const newToken = await ETokenGuardedMock.new(storage.address, token.address, false, { from: owner });
      const tokenE = UpgradeSupportE.wrap(token);

      await tokenE.upgrade(newToken.address, token.address, { from: owner });
    });
  });

  // Remainder of contract tested through EToken.
});
