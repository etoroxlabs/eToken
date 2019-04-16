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

/* global artifacts, web3, contract, assert */
/* eslint-env mocha */

'use strict';

const { shouldBehaveLikeERC20PublicAPI } =
      require('./ERC20/behaviors/ERC20.public.behavior.js');
const { shouldBehaveLikeERC20Mintable } =
      require('./ERC20/behaviors/ERC20Mintable.behavior.js');
const { shouldBehaveLikeERC20Burnable } =
      require('./ERC20/behaviors/ERC20Burnable.behavior.js');
const { shouldBehaveLikeERC20Pausable } =
      require('./ERC20/behaviors/ERC20Pausable.behavior.js');

const util = require('./../utils.js');

const Accesslist = artifacts.require('Accesslist');
const ETokenMock = artifacts.require('ETokenMock');
const EToken = artifacts.require('EToken');
const RevertingProxy = artifacts.require('RevertingProxy');
const ETokenE = require('./EToken.events.js');
const Storage = artifacts.require('Storage');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

const explicitSenderOps = [
  ['nameProxy', [util.ZERO_ADDRESS]],
  ['symbolProxy', [util.ZERO_ADDRESS]],
  ['decimalsProxy', [util.ZERO_ADDRESS]],
  ['totalSupplyProxy', [util.ZERO_ADDRESS]],
  ['balanceOfProxy', [util.ZERO_ADDRESS, util.ZERO_ADDRESS]],
  ['allowanceProxy', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, util.ZERO_ADDRESS]],
  ['transferProxy', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['approveProxy', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['transferFromProxy', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['increaseAllowanceProxy', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['decreaseAllowanceProxy', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['mintProxy', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['burnProxy', [util.ZERO_ADDRESS, 0]],
  ['burnFromProxy', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['changeMintingRecipientProxy', [util.ZERO_ADDRESS, util.ZERO_ADDRESS]],
  ['pauseProxy', [util.ZERO_ADDRESS]],
  ['unpauseProxy', [util.ZERO_ADDRESS]],
  ['pausedProxy', [util.ZERO_ADDRESS]]
];

const otherOps = [
  ['transfer', [util.ZERO_ADDRESS, 0]],
  ['approve', [util.ZERO_ADDRESS, 0]],
  ['transferFrom', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['increaseAllowance', [util.ZERO_ADDRESS, 0]],
  ['decreaseAllowance', [util.ZERO_ADDRESS, 0]],
  ['burn', [0]],
  ['burnFrom', [util.ZERO_ADDRESS, 0]],
  ['mint', [util.ZERO_ADDRESS, 0]],
  ['changeMintingRecipient', [util.ZERO_ADDRESS]],
  ['pause', []],
  ['unpause', []],
  ['paused', []]
];

function unupgradedTokenBehavior () {
  it('claims not to be upgraded', async function () {
    (await this.token.isUpgraded()).should.be.equal(false);
  });

  it('should return zero address for upgrade token', async function () {
    (await this.token.getUpgradedToken()).should.be.equal(util.ZERO_ADDRESS);
  });
}

function proxyTokenBehavior () {
  describe('proxy contract behavior', async function () {
    it('claims to be upgraded', async function () {
      (await this.token.isUpgraded()).should.be.equal(true);
    });

    it('should return zero address for upgrade token', async function () {
      (await this.token.getUpgradedToken()).should.be.equal(this.newToken.address);
    });
  });
}

function ERC20Permissions (owner, whitelisted, other, other1, blacklisted, blacklisted1,
                           blackwhite, blackwhite1) {
  describe('token permissions', function () {
    it('Rejects unprivileged transfer when both are non-whitelisted', async function () {
      await util.assertRevertsReason(
        this.token.transfer(other, 1, { from: other }),
        'no access');
    });

    it('Rejects unprivileged transfer when receiver are non-whitelisted', async function () {
      await util.assertRevertsReason(
        this.token.transfer(other, 10, { from: whitelisted }),
        'no access');
    });

    it('Rejects unprivileged transfer when sender are non-whitelisted', async function () {
      await util.assertRevertsReason(
        this.token.transfer(whitelisted, 10, { from: other }),
        'no access');
    });

    it('Rejects unprivileged transfer when both are blacklisted and none are whitelisted',
       async function () {
         await util.assertRevertsReason(
           this.token.transfer(blacklisted, 1, { from: blacklisted1 }),
           'no access');
       });

    it('Rejects unprivileged transfer when receiver is only blacklisted', async function () {
      await util.assertRevertsReason(
        this.token.transfer(blacklisted, 1, { from: whitelisted }),
        'no access');
    });

    it('Rejects unprivileged transfer when sender is only blacklisted', async function () {
      await util.assertRevertsReason(
        this.token.transfer(whitelisted, 1, { from: other }),
        'no access');
    });

    it('Rejects unprivileged transfer when sender and reciever are blacklisted and whitelisted',
       async function () {
         await util.assertRevertsReason(
           this.token.transfer(blackwhite1, 1, { from: blackwhite }),
           'no access');
       });

    it('Rejects unprivileged transfer when receiver is both blacklisted and whitelisted',
       async function () {
         await util.assertRevertsReason(
           this.token.transfer(blackwhite1, 1, { from: whitelisted }),
           'no access');
       });

    it('Rejects unprivileged transfer when sender is both blacklisted and whitelisted',
       async function () {
         await util.assertRevertsReason(
           this.token.transfer(whitelisted, 1, { from: blackwhite }),
           'no access');
       });

    it('Rejects unprivileged approve', async function () {
      await util.assertRevertsReason(
        this.token.approve(other, 1, { from: other }),
        'no access');
    });

    it('Rejects unprivileged transferFrom', async function () {
      await util.assertRevertsReason(
        this.token.transferFrom(other, other1, 1, { from: other }),
        'no access');
    });

    it('Rejects unprivileged burn', async function () {
      await util.assertRevertsReason(this.token.burn(1, { from: whitelisted }),
                                     'not burner');
    });

    it('Rejects unprivileged burnFrom', async function () {
      await util.assertRevertsReason(
        this.token.burnFrom(owner, 1, { from: whitelisted }),
        'not burner');
    });

    it('Rejects unprivileged increaseAllowance', async function () {
      await util.assertRevertsReason(
        this.token.increaseAllowance(whitelisted, 5, { from: other }),
        'no access');
    });

    it('Rejects unprivileged decreaseAllowance', async function () {
      await util.assertRevertsReason(
        this.token.decreaseAllowance(whitelisted, 5, { from: other }),
        'no access');
    });
  });
}

contract('EToken', async function (
  [owner, minter, pauser, otherPauser, burner, whitelistAdmin,
    whitelisted, whitelisted1, blacklisted, blacklisted1,
    blackwhite, blackwhite1, user, user1, ...restAccounts]) {
  const tokNameOrig = 'USDx';
  const tokNameUpgraded = 'USDxUp';

  const symbolOrig = 'e';
  const symbolUpgraded = 'f';

  const mintingRecipientAccount = '0x000000000000000000000000000000000000d00f';

  describe('constructor', function () {
    let storage;

    beforeEach(async function () {
      storage = await Storage.new(owner, owner, { from: owner });
    });

    it('reverts when both upgradedFrom and initialDeployment are set', async function () {
      await util.assertRevertsReason(
        ETokenMock.new(tokNameOrig, symbolOrig, 10,
                       0xf00f, true, util.ZERO_ADDRESS, mintingRecipientAccount,
                       0xf00f, true, owner, 100, { from: owner }),
        'Cannot both be upgraded and initial deployment.');
    });

    it('reverts when neither upgradedFrom nor initialDeployment are set', async function () {
      await util.assertRevertsReason(
        ETokenMock.new(tokNameOrig, symbolOrig, 10,
                       0xf00f, true, storage.address, mintingRecipientAccount,
                       0, false, owner, 100, { from: owner }),
        'Cannot both be upgraded and initial deployment.');
    });
  });

  describe('functionality', function () {
    // Tokens used during tests
    let token;
    let tokenE;
    let storage;
    let accesslist;
    let upgradeToken;

    beforeEach(async function () {
      accesslist = await Accesslist.new({ from: owner });

      token = await ETokenMock.new(tokNameOrig, symbolOrig, 10,
                                   accesslist.address, true, util.ZERO_ADDRESS,
                                   mintingRecipientAccount,
                                   0, true, owner, 100, { from: owner });
      storage = Storage.at(await token.getExternalStorage());

      tokenE = ETokenE.wrap(token);
      upgradeToken = await ETokenMock.new(
        tokNameUpgraded, symbolUpgraded, 20,
        accesslist.address, true, storage.address, mintingRecipientAccount,
        token.address, false, 0, 0, { from: owner });
      [token, upgradeToken].forEach(async function (f) {
        await f.addMinter(minter, { from: owner });
        await f.addPauser(pauser, { from: owner });
        await f.addBurner(burner, { from: owner });
      });

      await accesslist.addWhitelistAdmin(whitelistAdmin, { from: owner });

      await accesslist.addWhitelisted(owner, { from: owner });
      // Required by the burnFrom test
      await accesslist.addWhitelisted(burner, { from: owner });
      // Required by the pauser test
      await accesslist.addWhitelisted(otherPauser, { from: owner });
      await accesslist.addWhitelisted(pauser, { from: owner });
      await accesslist.addWhitelisted(whitelisted, { from: owner });
      await accesslist.addWhitelisted(whitelisted1, { from: owner });
      await accesslist.addWhitelisted(blackwhite, { from: owner });
      await accesslist.addWhitelisted(blackwhite1, { from: owner });

      await accesslist.addBlacklisted(blacklisted, { from: owner });
      await accesslist.addBlacklisted(blacklisted1, { from: owner });
      await accesslist.addBlacklisted(blackwhite, { from: owner });
      await accesslist.addBlacklisted(blackwhite1, { from: owner });
    });

    describe('Pre-upgrade', function () {
      beforeEach(function () {
        this.token = token;
      });

      describe('Original token', function () {
        unupgradedTokenBehavior();
        shouldBehaveLikeERC20PublicAPI(owner, whitelisted, whitelisted1);
        shouldBehaveLikeERC20Mintable(owner, minter, [user], mintingRecipientAccount);
        shouldBehaveLikeERC20Burnable(owner, 100, [burner]);
        shouldBehaveLikeERC20Pausable(owner, otherPauser,
                                      whitelisted, whitelisted1,
                                      restAccounts);
        ERC20Permissions(owner, whitelisted, user, user1, blacklisted,
                         blacklisted1, blackwhite, blackwhite1);

        it('rejects upgrade to null address', async function () {
          await util.assertRevertsReason(
            token.upgrade(util.ZERO_ADDRESS, { from: owner }),
            'Cannot upgrade to null address');
        });

        it('rejects upgrade to itself', async function () {
          await util.assertRevertsReason(
            token.upgrade(token.address, { from: owner }),
            'Cannot upgrade to myself');
        });

        it('reverts when doesn\'t own storage', async function () {
          await storage.transferImplementor(0xf00f);

          await util.assertRevertsReason(
            token.upgrade(upgradeToken.address, { from: owner }),
            'I don\'t own my storage. This will end badly.');
        });

        it('rejects upgrade from non-owner', async function () {
          await util.assertReverts(token.upgrade(
            upgradeToken.address, { from: whitelisted }));
        });

        it('upgrade emits event', async function () {
          await tokenE.upgrade(upgradeToken.address, token.address, { from: owner });
        });

        it('Returns orig token name', async function () {
          (await this.token.name()).should.be.equal(tokNameOrig);
        });

        it('Returns orig token symbol', async function () {
          (await this.token.symbol()).should.be.equal(symbolOrig);
        });

        it('Returns orig token decimals', async function () {
          (await this.token.decimals()).should.be.bignumber.equal(10);
        });
      });

      describe('New token', function () {
        describe('function permissions', function () {
          describe('unopgraded token is disabled', function () {
            const allOps = explicitSenderOps.concat(otherOps);
            allOps.forEach(function (op) {
              it(`${op[0]} reverts`, async function () {
                await util.assertRevertsReason(upgradeToken[op[0]](...op[1], { from: owner }),
                                               'Token disabled');
              });
            });
          });
        });
      });
    });

    describe('Post-upgrade', function () {
      function identifiesAsNewToken () {
        it('Returns new token name', async function () {
          (await this.token.name()).should.be.equal(tokNameUpgraded);
        });

        it('Returns new token symbol', async function () {
          (await this.token.symbol()).should.be.equal(symbolUpgraded);
        });

        it('Returns new token decimals', async function () {
          (await this.token.decimals()).should.be.bignumber.equal(20);
        });
      }

      describe('Upgraded token', function () {
        beforeEach(async function () {
          await token.upgrade(upgradeToken.address, { from: owner });
          this.token = upgradeToken;
        });
        afterEach(async function () {
          this.token = undefined;
        });

        shouldBehaveLikeERC20PublicAPI(owner, whitelisted, whitelisted1);
        shouldBehaveLikeERC20Mintable(owner, minter, [user], mintingRecipientAccount);
        shouldBehaveLikeERC20Burnable(owner, 100, [burner]);
        shouldBehaveLikeERC20Pausable(owner, otherPauser,
                                      whitelisted, whitelisted1,
                                      restAccounts);

        ERC20Permissions(owner, whitelisted, user, user1,
                         blacklisted, blacklisted1,
                         blackwhite, blackwhite1);
        identifiesAsNewToken();

        describe('Upgraded token rejects unauthorized for proxy sender functions', function () {
          it('should test for all the proxy methods', async function () {
            const methodsToTest = explicitSenderOps.map(o => o[0]).sort();
            const proxyMethods = Object.entries(this.token)
              .filter(
                ([key, value]) => key.endsWith('Proxy') &&
                      typeof value === 'function'
              )
              .map(o => o[0])
              .sort();

            assert.deepEqual(
              methodsToTest,
              proxyMethods,
              'Not all proxy methods are tested');
          });

          explicitSenderOps.forEach(function (op) {
            it(`${op[0]} reverts`, async function () {
              await util.assertRevertsReason(upgradeToken[op[0]](...op[1], { from: owner }),
                                             'Proxy is the only allowed caller');
            });
          });
        });
      });

      describe('Old token (proxy)', function () {
        beforeEach(async function () {
          await token.upgrade(upgradeToken.address, { from: owner });
          this.token = token;
          this.newToken = upgradeToken;
        });
        afterEach(async function () {
          this.token = undefined;
          this.newToken = undefined;
        });
        shouldBehaveLikeERC20PublicAPI(owner, whitelisted, whitelisted1);
        shouldBehaveLikeERC20Mintable(owner, minter, [user], mintingRecipientAccount);
        shouldBehaveLikeERC20Burnable(owner, 100, [burner]);
        ERC20Permissions(owner, whitelisted, user, user1,
                         blacklisted, blacklisted1,
                         blackwhite, blackwhite1);
        identifiesAsNewToken();
        proxyTokenBehavior(upgradeToken);

        it('reject if already upgraded', async function () {
          await util.assertRevertsReason(
            token.upgrade(upgradeToken.address, { from: owner }),
            'Token is already upgraded');
        });
      });
    });
  });

  describe('upgrade proxy chaining', function () {
    let accesslist;

    beforeEach(async function () {
      accesslist = await Accesslist.new({ from: owner });

      await accesslist.addWhitelisted(owner);
      await accesslist.addWhitelisted(minter);

      this.token = await ETokenMock.new(
        'upgraded', 'upg', 8, accesslist.address, true,
        util.ZERO_ADDRESS, owner, util.ZERO_ADDRESS,
        true, owner, 100
      );

      this.revertToken = await RevertingProxy.new();
    });

    describe('when upgraded once', function () {
      beforeEach(async function () {
        // Ensure 100% coverage
        await this.revertToken.upgrade(0);
        this.upgrade = function () {
          return this.token.upgrade(this.revertToken.address);
        };

        // Needed state changes for testing
        await this.token.addMinter(owner);
        await this.token.addBurner(minter);
        await this.token.approve(minter, 2);
      });

      proxyTests();
    });

    describe('when upgraded twice', function () {
      beforeEach(async function () {
        const storage = await this.token.getExternalStorage();

        this.upgradedToToken = await EToken.new(
          'upgraded2', 'upg2', 10, accesslist.address, true,
          storage, owner, this.token.address,
          false
        );

        await this.token.upgrade(this.upgradedToToken.address);

        this.revertToken = await RevertingProxy.new();
        this.upgrade = function () {
          return this.upgradedToToken.upgrade(this.revertToken.address);
        };

        // Needed state changes for testing
        await this.token.addMinter(owner);
        await this.token.addBurner(minter);
        await this.token.approve(minter, 2);
        await this.upgradedToToken.addMinter(owner);
        await this.upgradedToToken.addBurner(minter);
      });

      proxyTests();
    });
  });

  function proxyTests () {
    const upgradeOps = [
      ['name', []],
      ['symbol', []],
      ['decimals', []],
      ['totalSupply', []],
      ['balanceOf', [owner]],
      ['allowance', [owner, minter]],
      ['transfer', [minter, 1]],
      ['approve', [minter, 1]],
      ['transferFrom', [owner, minter, 1], minter],
      ['mint', [owner, 10]],
      ['burn', [10]],
      ['burnFrom', [owner, 1], minter],
      ['increaseAllowance', [minter, 1]],
      ['decreaseAllowance', [minter, 1]],
      ['changeMintingRecipient', [minter]],
      ['pause', []],
      ['unpause', [], undefined, (t) => t.pause()], // Pause before testing unpause
      ['paused', []]
    ];

    upgradeOps.forEach(function (u) {
      const name = u[0];
      const params = u[1];
      const from = u[2] === undefined ? owner : u[2];
      const preFn = u[3];

      it(`should proxy ${name} method`, async function () {
        preFn && await preFn(this.token);
        await this.token[name](...params, { from });
        await this.upgrade();
        await util.assertRevertsReason(this.token[name](...params, { from }), name);
      });
    });
  }
});
