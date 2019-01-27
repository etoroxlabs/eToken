/* global artifacts, web3, contract */
/* eslint-env mocha */

'use strict';

const util = require('./../utils.js');

const Accesslist = artifacts.require('Accesslist');
const ExternalERC20Storage = artifacts.require('ExternalERC20Storage');
const ETokenExplicitSender = artifacts.require('ETokenExplicitSenderMock');
const ETokenExplicitSenderE = require('./ETokenExplicitSender.events.js');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('ETokenExplicitSender', function ([owner, someAddress, ...rest]) {
  describe('finalizeUpgrade', function () {
    let accesslist;
    let storage;

    beforeEach(async function () {
      accesslist = await Accesslist.new({ from: owner });
      storage = await ExternalERC20Storage.new({ from: owner });
    });

    it('reverts when wrong contract finalizes upgrade', async function () {
      const token = await ETokenExplicitSender.new('tok', 't', 10,
                                                   accesslist.address, true, storage.address,
                                                   0xf00f, false, { from: owner });
      await util.assertReverts(token.finalizeUpgrade({ from: someAddress }),
                                     'Sender is not old contract');
    });

    it('emits UpgradeFinalized event', async function () {
      const token = await ETokenExplicitSender.new(
        'tok', 't', 10, accesslist.address, true, storage.address,
        owner, false, { from: owner });

      const tokenE = ETokenExplicitSenderE.wrap(token);

      await tokenE.finalizeUpgrade(owner, { from: owner });
    });
  });
  // Remainder of contract tested through EToken.
});
