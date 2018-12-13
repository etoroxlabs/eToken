/* global artifacts, contract, assert */
/* eslint-env mocha */

'use strict'

const util = require('./utils.js')
const { inLogs } =
      require('etokenize-openzeppelin-solidity/test/helpers/expectEvent.js')
const truffleAssert = require('truffle-assertions')

const Accesslist = artifacts.require('Accesslist')
const AccesslistGuardedMock = artifacts.require('AccesslistGuardedMock')

contract('Accesslist', async function ([owner, user, user1, user2, user3,
  user4, user5, user6, ...accounts]) {
  beforeEach(async function () {
    this.accesslist = await Accesslist.new()
    this.accesslistGuardedMock = await AccesslistGuardedMock.new(this.accesslist.address)
    const { logs } =
              await truffleAssert.createTransactionResult(this.accesslist,
                this.accesslist.transactionHash)
    inLogs(logs, 'OwnershipTransferred',
      { previousOwner: util.ZERO_ADDRESS,
        newOwner: owner })
    inLogs(logs, 'WhitelistAdminAdded', { account: owner })
    inLogs(logs, 'BlacklistAdminAdded', { account: owner })
  })

  it('should reject null address accesslist', async function () {
    await util.assertReverts(AccesslistGuardedMock.new(util.ZERO_ADDRESS))
  })
  it('allows privileged privilege propagation: whitelist', async function () {
    assert(!(await this.accesslist.isWhitelistAdmin.call(user4, { from: owner })))
    await util.assertReverts(this.accesslist.addWhitelisted(user4, { from: user3 }))
    await this.accesslist.addWhitelistAdmin(user3, { from: owner })
    assert(await this.accesslist.isWhitelistAdmin.call(user3, { from: owner }))
    await this.accesslist.addWhitelisted(user4, { from: user3 })
    assert(await this.accesslist.isWhitelisted(user4, { from: user3 }))
  })

  it('rejects unprivileged privilege propagation: whitelist', async function () {
    assert(!(await this.accesslist.isWhitelistAdmin.call(user6, { from: user5 })))
    await util.assertReverts(this.accesslist.addWhitelisted(user6, { from: user5 }))
    await util.assertReverts(this.accesslist.addWhitelistAdmin(user6, { from: user5 }))
    assert(!(await this.accesslist.isWhitelistAdmin.call(user6, { from: user5 })))
    await util.assertReverts(this.accesslist.addWhitelisted(user6, { from: user5 }))
  })

  it('allows privileged privilege propagation: blacklist', async function () {
    assert(!(await this.accesslist.isBlacklistAdmin.call(user4, { from: owner })))
    await util.assertReverts(this.accesslist.addBlacklisted(user4, { from: user3 }))
    await this.accesslist.addBlacklistAdmin(user3, { from: owner })
    assert(await this.accesslist.isBlacklistAdmin.call(user3, { from: owner }))
    await this.accesslist.addBlacklisted(user4, { from: user3 })
    assert(await this.accesslist.isBlacklisted(user4, { from: user3 }))
  })

  it('rejects unprivileged privilege propagation: blacklist', async function () {
    assert(!(await this.accesslist.isBlacklistAdmin.call(user6, { from: user5 })))
    await util.assertReverts(this.accesslist.addBlacklisted(user6, { from: user5 }))
    await util.assertReverts(this.accesslist.addBlacklistAdmin(user6, { from: user5 }))
    assert(!(await this.accesslist.isBlacklistAdmin.call(user6, { from: user5 })))
    await util.assertReverts(this.accesslist.addBlacklisted(user6, { from: user5 }))
  })

  describe('Blacklisting', async function () {
    it('is initially not in blacklist from unprivileged', async function () {
      assert(!(await this.accesslist.isBlacklisted.call(user, { from: user1 })))
    })

    it('is initially not in blacklist from privileged', async function () {
      assert(!(await this.accesslist.isBlacklisted.call(user, { from: owner })))
    })

    async function addBlacklisted (t, user, from) {
      const { logs } = await t.accesslist.addBlacklisted(user, { from: owner })
      inLogs(logs, 'BlacklistAdded')
    }

    it('allows privileged to add to blacklist', async function () {
      assert(!(await this.accesslist.isBlacklisted.call(user, { from: owner })))
      addBlacklisted(this, user, owner)
      assert(await this.accesslist.isBlacklisted.call(user, { from: owner }))
    })

    it('rejects if user is blacklisted', async function () {
      assert(await this.accesslistGuardedMock.requireNotBlacklistedMock.call(user))
      addBlacklisted(this, user, owner)
      await util.assertReverts(this.accesslistGuardedMock.requireNotBlacklistedMock.call(user))
    })

    it('rejects if caller is blacklisted', async function () {
      assert(await this.accesslistGuardedMock.onlyNotBlacklistedMock.call({ from: user }))
      addBlacklisted(this, user, owner)
      await util.assertReverts(this.accesslistGuardedMock.onlyNotBlacklistedMock.call({ from: user }))
    })

    it('rejects privileged attempt to add same user to blacklist multiple times', async function () {
      assert(!(await this.accesslist.isBlacklisted.call(user2, { from: owner })))
      addBlacklisted(this, user2, owner)
      await util.assertReverts(this.accesslist.addBlacklisted(user2, { from: owner }))
      assert((await this.accesslist.isBlacklisted.call(user2, { from: owner })))
    })

    it('allows privileged to remove from blacklist', async function () {
      assert(!(await this.accesslist.isBlacklisted.call(user1, { from: owner })))
      await this.accesslist.addBlacklisted(user1, { from: owner })
      assert(await this.accesslist.isBlacklisted.call(user1, { from: owner }))
      await this.accesslist.removeBlacklisted(user1, { from: owner })
      assert(!(await this.accesslist.isBlacklisted.call(user1, { from: owner })))
    })

    it('rejects unprivileged from removing from blacklist', async function () {
      await this.accesslist.addBlacklisted(user3, { from: owner })
      util.assertReverts(this.accesslist.removeBlacklisted(user3, { from: user2 }))
      assert(await this.accesslist.isBlacklisted.call(user3, { from: user2 }))
    })
  })
  describe('Whitelisting', async function () {
    it('is initially not in whitelist from unprivileged', async function () {
      assert(!(await this.accesslist.isWhitelisted.call(user, { from: user1 })))
    })

    it('is initially not in whitelist from privileged', async function () {
      assert(!(await this.accesslist.isWhitelisted.call(user, { from: owner })))
    })

    async function addWhitelisted (t, user, from) {
      const { logs } = await t.accesslist.addWhitelisted(user, { from: owner })
      inLogs(logs, 'WhitelistAdded')
    }

    it('allows privileged to add to whitelist', async function () {
      assert(!(await this.accesslist.isWhitelisted.call(user, { from: owner })))
      addWhitelisted(this, user, owner)
      assert(await this.accesslist.isWhitelisted.call(user, { from: owner }))
    })

    it('rejects if user is not whitelisted', async function () {
      await util.assertReverts(this.accesslistGuardedMock.requireWhitelistedMock.call(user))
      addWhitelisted(this, user, owner)
      assert(await this.accesslistGuardedMock.requireWhitelistedMock.call(user))
    })

    it('rejects if caller is whitelisted', async function () {
      await util.assertReverts(this.accesslistGuardedMock.onlyWhitelistedMock.call({ from: user }))
      addWhitelisted(this, user, owner)
      assert(await this.accesslistGuardedMock.onlyWhitelistedMock.call({ from: user }))
    })

    it('rejects privileged attempt to add same user to whitelist multiple times', async function () {
      assert(!(await this.accesslist.isWhitelisted.call(user2, { from: owner })))
      addWhitelisted(this, user2, owner)
      await util.assertReverts(this.accesslist.addWhitelisted(user2, { from: owner }))
      assert(await this.accesslist.isWhitelisted.call(user2, { from: owner }))
    })

    it('allows privileged to remove from whitelist', async function () {
      assert(!(await this.accesslist.isWhitelisted.call(user1, { from: owner })))
      await this.accesslist.addWhitelisted(user1, { from: owner })
      assert((await this.accesslist.isWhitelisted.call(user1, { from: owner })))
      await this.accesslist.removeWhitelisted(user1, { from: owner })
      assert(!(await this.accesslist.isWhitelisted.call(user1, { from: owner })))
    })

    it('rejects unprivileged from adding to whitelist', async function () {
      assert(!(await this.accesslist.isWhitelisted.call(user3, { from: user2 })))
      await util.assertReverts(this.accesslist.addWhitelisted(user3, { from: user2 }))
      assert(!(await this.accesslist.isWhitelisted.call(user3, { from: user2 })))
    })

    it('rejects unprivileged from removing from whitelist', async function () {
      await this.accesslist.addWhitelisted(user3, { from: owner })
      util.assertReverts(this.accesslist.removeWhitelisted(user3, { from: user2 }))
      assert(await this.accesslist.isWhitelisted.call(user3, { from: user2 }))
    })
  })
})
