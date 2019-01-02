/* global artifacts, contract, assert */
/* eslint-env mocha */

'use strict';

const util = require('./utils.js');
const { inLogs } = require('openzeppelin-solidity/test/helpers/expectEvent.js');
const truffleAssert = require('truffle-assertions');

const Accesslist = artifacts.require('Accesslist');
const AccesslistGuardedMock = artifacts.require('AccesslistGuardedMock');

contract('Accesslist', async function (
  [owner, user, user1, ...accounts]
) {
  let accesslist;
  let accesslistGuardedMock;

  beforeEach(async function () {
    accesslist = await Accesslist.new();
    accesslistGuardedMock =
      await AccesslistGuardedMock.new(accesslist.address, true);
  });

  describe('constructor', function () {
    beforeEach(async function () {
      const { logs } =
            await truffleAssert.createTransactionResult(
              accesslist, accesslist.transactionHash);
      this.logs = logs;
    });

    it('emits OwnershipTransferred event', function () {
      inLogs(this.logs, 'OwnershipTransferred',
             { previousOwner: util.ZERO_ADDRESS,
               newOwner: owner });
    });

    it('emits BlacklistAdminAdded event', function () {
      inLogs(this.logs, 'BlacklistAdminAdded', { account: owner });
    });

    it('emits WhitelistAdminAdded event', function () {
      inLogs(this.logs, 'WhitelistAdminAdded', { account: owner });
    });
  });

  it('should reject null address accesslist', async function () {
    await util.assertReverts(AccesslistGuardedMock.new(util.ZERO_ADDRESS, true));
  });

  it('allows privileged privilege propagation: whitelist', async function () {
    assert(!(await accesslist.isWhitelistAdmin(user, { from: owner })));
    await util.assertReverts(accesslist.addWhitelisted(user, { from: user1 }));
    await accesslist.addWhitelistAdmin(user, { from: owner });
    assert(await accesslist.isWhitelistAdmin(user, { from: owner }));
    await accesslist.addWhitelisted(user, { from: user });
    assert(await accesslist.isWhitelisted(user, { from: user1 }));
  });

  it('rejects unprivileged privilege propagation: whitelist', async function () {
    assert(!(await accesslist.isWhitelistAdmin(user, { from: user1 })));
    await util.assertReverts(accesslist.addWhitelisted(user, { from: user1 }));
    await util.assertReverts(accesslist.addWhitelistAdmin(user, { from: user1 }));
    assert(!(await accesslist.isWhitelistAdmin(user, { from: user1 })));
    await util.assertReverts(accesslist.addWhitelisted(user, { from: user1 }));
  });

  it('allows privileged privilege propagation: blacklist', async function () {
    assert(!(await accesslist.isBlacklistAdmin(user, { from: owner })));
    await util.assertReverts(accesslist.addBlacklisted(user, { from: user1 }));
    await accesslist.addBlacklistAdmin(user1, { from: owner });
    assert(await accesslist.isBlacklistAdmin(user1, { from: owner }));
    await accesslist.addBlacklisted(user, { from: user1 });
    assert(await accesslist.isBlacklisted(user, { from: user1 }));
  });

  it('rejects unprivileged privilege propagation: blacklist', async function () {
    assert(!(await accesslist.isBlacklistAdmin(user1, { from: user })));
    await util.assertReverts(accesslist.addBlacklisted(user1, { from: user }));
    await util.assertReverts(accesslist.addBlacklistAdmin(user1, { from: user }));
    assert(!(await accesslist.isBlacklistAdmin(user1, { from: user })));
    await util.assertReverts(accesslist.addBlacklisted(user1, { from: user }));
  });

  describe('Blacklisting', async function () {
    it('is initially not in blacklist from unprivileged', async function () {
      assert(!(await accesslist.isBlacklisted(user, { from: user1 })));
    });

    it('is initially not in blacklist from privileged', async function () {
      assert(!(await accesslist.isBlacklisted(user, { from: owner })));
    });

    async function addBlacklisted (al, user, from) {
      const { logs } = await al.addBlacklisted(user, { from: owner });
      inLogs(logs, 'BlacklistAdded');
    }

    it('allows privileged to add to blacklist', async function () {
      assert(!(await accesslist.isBlacklisted(user, { from: owner })));
      addBlacklisted(accesslist, user, owner);
      assert(await accesslist.isBlacklisted(user, { from: owner }));
    });

    it('rejects if user is blacklisted', async function () {
      assert(await accesslistGuardedMock.requireNotBlacklistedMock(user));
      addBlacklisted(accesslist, user, owner);
      await util.assertReverts(accesslistGuardedMock.requireNotBlacklistedMock(user));
    });

    it('rejects if caller is blacklisted', async function () {
      assert(await accesslistGuardedMock.onlyNotBlacklistedMock({ from: user }));
      addBlacklisted(accesslist, user, owner);
      await util.assertReverts(accesslistGuardedMock.onlyNotBlacklistedMock({ from: user }));
    });

    it('rejects privileged attempt to add same user to blacklist multiple times', async function () {
      assert(!(await accesslist.isBlacklisted(user1, { from: owner })));
      addBlacklisted(accesslist, user1, owner);
      await util.assertReverts(accesslist.addBlacklisted(user1, { from: owner }));
      assert((await accesslist.isBlacklisted(user1, { from: owner })));
    });

    it('allows privileged to remove from blacklist', async function () {
      assert(!(await accesslist.isBlacklisted(user1, { from: owner })));
      await accesslist.addBlacklisted(user1, { from: owner });
      assert(await accesslist.isBlacklisted(user1, { from: owner }));
      await accesslist.removeBlacklisted(user1, { from: owner });
      assert(!(await accesslist.isBlacklisted(user1, { from: owner })));
    });

    it('rejects unprivileged from removing from blacklist', async function () {
      await accesslist.addBlacklisted(user, { from: owner });
      util.assertReverts(accesslist.removeBlacklisted(user, { from: user1 }));
      assert(await accesslist.isBlacklisted(user, { from: user1 }));
    });
  });

  describe('Whitelisting', async function () {
    it('is initially not in whitelist from unprivileged', async function () {
      assert(!(await accesslist.isWhitelisted(user, { from: user1 })));
    });

    it('is initially not in whitelist from privileged', async function () {
      assert(!(await accesslist.isWhitelisted(user, { from: owner })));
    });

    async function addWhitelisted (al, user, from) {
      const { logs } = await al.addWhitelisted(user, { from: owner });
      inLogs(logs, 'WhitelistAdded');
    }

    it('allows privileged to add to whitelist', async function () {
      assert(!(await accesslist.isWhitelisted(user, { from: owner })));
      addWhitelisted(accesslist, user, owner);
      assert(await accesslist.isWhitelisted(user, { from: owner }));
    });

    it('rejects if user is not whitelisted', async function () {
      await util.assertReverts(accesslistGuardedMock.requireWhitelistedMock(user));
      addWhitelisted(accesslist, user, owner);
      assert(await accesslistGuardedMock.requireWhitelistedMock(user));
    });

    it('rejects if caller is whitelisted', async function () {
      await util.assertReverts(accesslistGuardedMock.onlyWhitelistedMock({ from: user }));
      addWhitelisted(accesslist, user, owner);
      assert(await accesslistGuardedMock.onlyWhitelistedMock({ from: user }));
    });

    it('rejects privileged attempt to add same user to whitelist multiple times', async function () {
      assert(!(await accesslist.isWhitelisted(user, { from: owner })));
      addWhitelisted(accesslist, user, owner);
      await util.assertReverts(accesslist.addWhitelisted(user, { from: owner }));
      assert(await accesslist.isWhitelisted(user, { from: owner }));
    });

    it('allows privileged to remove from whitelist', async function () {
      assert(!(await accesslist.isWhitelisted(user, { from: owner })));
      await accesslist.addWhitelisted(user, { from: owner });
      assert((await accesslist.isWhitelisted(user, { from: owner })));
      await accesslist.removeWhitelisted(user, { from: owner });
      assert(!(await accesslist.isWhitelisted(user, { from: owner })));
    });

    it('rejects unprivileged from adding to whitelist', async function () {
      assert(!(await accesslist.isWhitelisted(user, { from: user1 })));
      await util.assertReverts(accesslist.addWhitelisted(user, { from: user1 }));
      assert(!(await accesslist.isWhitelisted(user, { from: user1 })));
    });

    it('rejects unprivileged from removing from whitelist', async function () {
      await accesslist.addWhitelisted(user, { from: owner });
      util.assertReverts(accesslist.removeWhitelisted(user, { from: user1 }));
      assert(await accesslist.isWhitelisted(user, { from: user1 }));
    });
  });

  describe('when whitelist is not enabled', function () {
    beforeEach(async function () {
      accesslistGuardedMock = await AccesslistGuardedMock.new(
        accesslist.address,
        false
      );
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
        await util.assertReverts(
          accesslistGuardedMock.requireHasAccessMock(user)
        );
      });

      it('should revert onlyHasAccess', async function () {
        await util.assertReverts(
          accesslistGuardedMock.onlyHasAccessMock({ from: user })
        );
      });
    });

    describe('if blacklisted and whitelisted', function () {
      beforeEach(async function () {
        await accesslist.addWhitelisted(user, { from: owner });
        await accesslist.addBlacklisted(user, { from: owner });
      });

      it('should revert requireHasAccess', async function () {
        await util.assertReverts(
          accesslistGuardedMock.requireHasAccessMock(user)
        );
      });

      it('should revert onlyHasAccess', async function () {
        await util.assertReverts(
          accesslistGuardedMock.onlyHasAccessMock({ from: user })
        );
      });
    });
  });
});
