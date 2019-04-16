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

/* global artifacts, contract */
/* eslint-env mocha */

'use strict';

const util = require('../../utils.js');

const Accesslist = artifacts.require('Accesslist');
const AccesslistE = require('./Accesslist.events.js');
const AccesslistGuardedMock = artifacts.require('AccesslistGuardedMock');

contract('Accesslist', async function (
  [owner, user, user1, ...accounts]
) {
  let accesslist;
  let accesslistE;

  beforeEach(async function () {
    accesslist = await Accesslist.new();
    accesslistE = AccesslistE.wrap(accesslist);
  });

  describe('constructor', function () {
    it('emits events', async function () {
      await accesslistE.constructor(accesslist, owner);
    });

    it('should reject null address accesslist', async function () {
      await util.assertRevertsReason(
        AccesslistGuardedMock.new(util.ZERO_ADDRESS, true),
        'Supplied accesslist is null');
    });
  });

  describe('when whitelist is enabled', function () {
    let accesslistGuardedMock;

    beforeEach(async function () {
      accesslistGuardedMock =
        await AccesslistGuardedMock.new(accesslist.address, true);
    });

    describe('blacklisted', function () {
      beforeEach(async function () {
        accesslist.addBlacklisted(user, { from: owner });
      });

      it('emits event when adding to blacklist', async function () {
        accesslistE.addBlacklisted(user1, { from: owner });
      });

      it('says that blacklisted user is blacklsited', async function () {
        (await accesslist.isBlacklisted(user, { from: owner })).should.be.equal(true);
      });

      it('says that non-blacklisted user is not blacklsited', async function () {
        (await accesslist.isBlacklisted(user1, { from: owner })).should.be.equal(false);
      });

      it('allows blacklist admin to add to blacklist', async function () {
        await accesslist.addBlacklistAdmin(user, { from: owner });
        await accesslist.addBlacklisted(user1, { from: user });
      });

      it('guarded function reverts if user is blacklisted', async function () {
        await util.assertRevertsReason(
          accesslistGuardedMock.requireNotBlacklistedMock(user), 'no access');
      });

      it('guarded function reverts if caller is blacklisted', async function () {
        await util.assertRevertsReason(
          accesslistGuardedMock.onlyNotBlacklistedMock({ from: user }), 'no access');
      });

      it('reverts when adding same user to blacklist multiple times', async function () {
        await util.assertRevertsNotReason(accesslist.addBlacklisted(user, { from: owner }),
                                          'no access');
      });

      it('allows privileged to remove from blacklist', async function () {
        await accesslist.removeBlacklisted(user, { from: owner });
        (await accesslist.isBlacklisted(user, { from: owner })).should.be.equal(false);
      });

      it('emits event when removing from blacklist', async function () {
        await accesslistE.removeBlacklisted(user, { from: owner });
      });

      it('reverts when non-admin adds to blacklist ', async function () {
        await util.assertReverts(accesslist.addBlacklisted(user, { from: user1 }),
                                 'not blacklistAdmin');
      });

      it('reverts when non-admin removes from blacklist', async function () {
        util.assertRevertsReason(accesslist.removeBlacklisted(user, { from: user1 }),
                                 'not blacklistAdmin');
      });
    });

    describe('whitelisted', function () {
      beforeEach(async function () {
        accesslist.addWhitelisted(user, { from: owner });
      });

      it('says that whitelisted user is blacklsited', async function () {
        (await accesslist.isWhitelisted(user, { from: owner })).should.be.equal(true);
      });

      it('says that non-whitelisted user is not blacklsited', async function () {
        (await accesslist.isWhitelisted(user1, { from: owner })).should.be.equal(false);
      });

      it('allows blacklist admin to add to blacklist', async function () {
        await accesslist.addBlacklistAdmin(user, { from: owner });
        await accesslist.addBlacklisted(user1, { from: user });
      });

      it('requireWhitelisted guard reverts if user is not whitelisted', async function () {
        await util.assertRevertsReason(
          accesslistGuardedMock.requireWhitelistedMock(user1), 'no access');
      });

      it('onlyWhitelisted guard reverts if caller is not whitelisted', async function () {
        await util.assertRevertsReason(
          accesslistGuardedMock.onlyWhitelistedMock({ from: user1 }), 'no access');
      });

      it('requireWhitelisted guard succeeds if user is whitelisted', async function () {
        (await accesslistGuardedMock.requireWhitelistedMock(user, { from: owner }))
          .should.be.equal(true);
      });

      it('onlyWitelisted guard succeeds if user is whitelisted', async function () {
        (await accesslistGuardedMock.onlyWhitelistedMock({ from: user }))
          .should.be.equal(true);
      });

      it('requireNotBlacklisted guard succeeds if user not blacklisted', async function () {
        (await accesslistGuardedMock.requireNotBlacklistedMock(user, { from: owner }))
          .should.be.equal(true);
      });

      it('onlyNotBlacklisted guard succeeds if user not blacklisted', async function () {
        (await accesslistGuardedMock.onlyNotBlacklistedMock({ from: user }))
          .should.be.equal(true);
      });

      it('reverts when adding same user to whitelist multiple times', async function () {
        await util.assertRevertsNotReason(
          accesslist.addWhitelisted(user, { from: owner }), 'no access');
      });

      it('allows removing from whitelsit when admin', async function () {
        await accesslist.removeWhitelisted(user, { from: owner });
        (await accesslist.isWhitelisted(user, { from: owner }))
          .should.be.equal(false);
      });

      it('emits event when removing from whitelist', async function () {
        await accesslistE.removeWhitelisted(user, { from: owner });
      });

      it('reverts when non-admin adds to whitelist ', async function () {
        await util.assertReverts(accesslist.addWhitelisted(user, { from: user1 }),
                                 'not whitelistAdmin');
      });

      it('reverts when non-admin removes from whitelist', async function () {
        util.assertRevertsReason(accesslist.removeWhitelisted(user, { from: user1 }),
                                 'not whitelistAdmin');
      });
    });

    describe('blacklisted and whitelisted', function () {
      beforeEach(async function () {
        accesslist.addWhitelisted(user, { from: owner });
        accesslist.addBlacklisted(user, { from: owner });
      });

      it('requireHasAccess reverts', async function () {
        await util.assertRevertsReason(
          accesslistGuardedMock.requireHasAccessMock(user),
          'no access');
      });

      it('onlyHasAccess reverts', async function () {
        await util.assertRevertsReason(
          accesslistGuardedMock.onlyHasAccessMock({ from: user }),
          'no access');
      });
    });
  });

  describe('when whitelist is disabled', function () {
    let accesslistGuardedMock;

    beforeEach(async function () {
      accesslistGuardedMock =
        await AccesslistGuardedMock.new(accesslist.address, false);
    });

    describe('if whitelisted', function () {
      beforeEach(async function () {
        await accesslist.addWhitelisted(user, { from: owner });
      });

      it('should allow requireHasAccess', async function () {
        (await accesslistGuardedMock.requireHasAccessMock(user))
          .should.be.equal(true);
      });

      it('should allow onlyHasAccess', async function () {
        (await accesslistGuardedMock.onlyHasAccessMock({ from: user }))
          .should.be.equal(true);
      });
    });

    describe('if not whitelisted', function () {
      it('should allow requireHasAccess', async function () {
        (await accesslistGuardedMock.requireHasAccessMock(user))
          .should.be.equal(true);
      });

      it('should allow onlyHasAccess', async function () {
        (await accesslistGuardedMock.onlyHasAccessMock({ from: user }))
          .should.be.equal(true);
      });
    });

    describe('if blacklisted', function () {
      beforeEach(async function () {
        await accesslist.addBlacklisted(user, { from: owner });
      });

      it('should revert requireHasAccess', async function () {
        await util.assertRevertsReason(
          accesslistGuardedMock.requireHasAccessMock(user),
          'no access');
      });

      it('should revert onlyHasAccess', async function () {
        await util.assertRevertsReason(
          accesslistGuardedMock.onlyHasAccessMock({ from: user }),
          'no access');
      });
    });

    describe('if blacklisted and whitelisted', function () {
      beforeEach(async function () {
        await accesslist.addWhitelisted(user, { from: owner });
        await accesslist.addBlacklisted(user, { from: owner });
      });

      it('should revert requireHasAccess', async function () {
        await util.assertRevertsReason(
          accesslistGuardedMock.requireHasAccessMock(user),
          'no access');
      });

      it('should revert onlyHasAccess', async function () {
        await util.assertRevertsReason(
          accesslistGuardedMock.onlyHasAccessMock({ from: user }),
          'no access');
      });
    });
  });
});
