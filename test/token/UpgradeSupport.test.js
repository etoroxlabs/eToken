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

contract('ETokenExplicitSender', function ([owner, someAddress, ...rest]) {
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
