/* global artifacts, web3, contract */
/* eslint-env mocha */

'use strict';

const util = require('./../utils.js');

const Accesslist = artifacts.require('Accesslist');
const ExternalERC20Storage = artifacts.require('ExternalERC20Storage');
const TokenXExplicitSender = artifacts.require('TokenXExplicitSenderMock');
const TokenXExplicitSenderE = require('./TokenXExplicitSender.events.js');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('TokenXExplicitSender', function ([owner, someAddress, ...rest]) {
  describe('finalizeUpgrade', function () {
    let accesslist;
    let storage;

    beforeEach(async function () {
      accesslist = await Accesslist.new({ from: owner });
      storage = await ExternalERC20Storage.new({ from: owner });
    });

    it('reverts when no upgradeFrom contract is set', async function () {
      const token = await TokenXExplicitSender.new('tok', 't', 10,
                                                   accesslist.address, true, storage.address,
                                                   0, true, { from: owner });
      await util.assertRevertsReason(token.finalizeUpgrade({ from: someAddress }),
                                     'Must have a contract to upgrade from');
    });

    it('reverts when wrong contract finalizes upgrade', async function () {
      const token = await TokenXExplicitSender.new('tok', 't', 10,
                                                   accesslist.address, true, storage.address,
                                                   0xf00f, false, { from: owner });
      await util.assertRevertsReason(token.finalizeUpgrade({ from: someAddress }),
                                     'Sender is not old contract');
    });

    it('emits UpgradeFinalized event', async function () {
      const token = await TokenXExplicitSender.new(
        'tok', 't', 10, accesslist.address, true, storage.address,
        owner, false, { from: owner });

      const tokenE = TokenXExplicitSenderE.wrap(token);

      await tokenE.finalizeUpgrade(owner, owner, { from: owner });
    });
  });
  // Remainder of contract tested through TokenX.
});
