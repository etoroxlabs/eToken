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

/* global artifacts, contract, assert, web3 */
/* eslint-env mocha */

'use strict';

const util = require('./utils.js');
const { shouldBehaveLikeOwnable } =
      require('openzeppelin-solidity/test/ownership/Ownable.behavior.js');

const TokenManager = artifacts.require('TokenManager');

const TokenManagerE = require('./TokenManager.events.js');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('TokenManager', async ([owner, otherAccount, ...accounts]) => {
  let tokMgr;
  let tokMgrE;

  const tokens = [
    { address: new BigNumber(0xf00d),
      name: 'tok1' },
    { address: new BigNumber(0xf00e),
      name: 'tok2' }];
  const otherToken = { address: new BigNumber(0xf00f),
                       name: 'tok3' };

  beforeEach(async function () {
    tokMgr = await TokenManager.new();
    tokMgrE = TokenManagerE.wrap(tokMgr);
  });

  describe('behaves', function () {
    beforeEach(async function () {
      this.ownable = tokMgr;
    });

    shouldBehaveLikeOwnable(owner, [otherAccount]);
  });

  describe('when empty', function () {
    it('reverts when adding null-token', async function () {
      const nulltoken = util.ZERO_ADDRESS;
      await util.assertRevertsReason(
        tokMgr.addToken('nulltoken', nulltoken, { from: owner }),
        'Supplied token is null');
    });

    it('reverts when retrieving non-existing entries', async function () {
      await util.assertRevertsReason(
        tokMgr.getToken('someToken', { from: otherAccount }),
        'Token does not exist');
    });

    it('returns an empty list of tokens', async function () {
      const expected = [];
      const r = await tokMgr.getTokens({ from: owner });
      assert.deepEqual(r, expected);
    });

    it('should add token', async function () {
      await tokMgr.addToken(otherToken.name, otherToken.address,
                            { from: owner });
      (await tokMgr.getToken(otherToken.name))
        .should.be.bignumber.equal(otherToken.address);
    });

    it('addToken emits event', async function () {
      await tokMgrE.addToken(otherToken.name, otherToken.address,
                             { from: owner });
    });
  });

  describe('When non-empty', function () {
    beforeEach(function () {
      tokens.forEach(async (x) => {
        await tokMgr.addToken(x.name, x.address, { from: owner });
      });
    });

    tokens.forEach(function (x) {
      it(`should retrieve token ${x.name}`, async function () {
        (await tokMgr.getToken(x.name)).should.be.bignumber.equal(x.address);
      });
    });

    it('Elements are set to 0 when deleted', async function () {
      // Delete existing tokens
      await Promise.all(
        tokens.map(x => tokMgr.deleteToken(x.name, { from: owner }))
      );

      const newExpected = [0, 0];
      const actual = (await tokMgr.getTokens({ from: owner }))
        .map((x) => parseInt(x));

      assert.deepEqual(
        actual, newExpected,
        'Token list returned does not match expected'
      );
    });

    it('should upgrade token', async function () {
      await tokMgr.upgradeToken(tokens[0].name, otherToken.address,
                                { from: owner });

      (await tokMgr.getToken(tokens[0].name, { from: owner }))
        .should.be.bignumber.equal(otherToken.address);
    });

    it('emits upgrade event', async function () {
      await tokMgrE.upgradeToken(tokens[0].name, otherToken.address,
                                 tokens[0].address, { from: owner });
    });

    it('returns a list of created tokens', async function () {
      const expected = tokens.map((x) => x.name);
      const r = (await tokMgr.getTokens({ from: owner }))
        .map(util.bytes32ToString);

      // Sort arrays since implementation
      // does not require stable order of tokens
      assert.deepEqual(
        r.sort(), expected.sort(),
        'Token list returned does not match expected'
      );
    });

    it('reverts when upgrading non-existing token', async function () {
      await util.assertRevertsReason(
        tokMgr.upgradeToken('noToken', 0xf00, { from: owner }),
        'Token does not exist');
    });

    it('fails on duplicated names', async function () {
      await util.assertReverts(
        tokMgr.addToken(tokens[1].name, tokens[1].address, { from: owner })
      );
    });

    it('should properly remove tokens', async function () {
      await tokMgr.deleteToken(tokens[1].name, { from: owner });

      await util.assertReverts(tokMgr.getToken(tokens[1].name,
                                               { from: owner }));
    });

    it('should emit deleteToken event', async function () {
      await tokMgrE.deleteToken(tokens[1].name, tokens[1].address, { from: owner });
    });
  });

  describe('reverts when not owner', () => {
    it('addToken', async function () {
      await util.assertReverts(tokMgr.addToken(
        tokens[0].name, tokens[0].address,
        { from: otherAccount }
      ));
    });

    it('Rejects unauthorized deleteToken', async function () {
      await util.assertRevertsNotReason(
        tokMgr.deleteToken(tokens[0].name, { from: otherAccount }),
        'Token does not exist');
    });

    it('Rejects unauthorized upgradeToken', async function () {
      await util.assertRevertsNotReason(
        tokMgr.upgradeToken(tokens[0].name, tokens[0].address,
                            { from: otherAccount }),
        'Token does not exist');
    });
  });
});
