/* global artifacts, web3, contract */
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
const TokenXMock = artifacts.require('TokenXMock');
const ExternalERC20Storage = artifacts.require('ExternalERC20Storage');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

const explicitSenderOps = [
  ['nameExplicitSender', [util.ZERO_ADDRESS]],
  ['symbolExplicitSender', [util.ZERO_ADDRESS]],
  ['decimalsExplicitSender', [util.ZERO_ADDRESS]],
  ['totalSupplyExplicitSender', [util.ZERO_ADDRESS]],
  ['balanceOfExplicitSender', [util.ZERO_ADDRESS, util.ZERO_ADDRESS]],
  ['allowanceExplicitSender', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, util.ZERO_ADDRESS]],
  ['transferExplicitSender', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['approveExplicitSender', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['transferFromExplicitSender', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['increaseAllowanceExplicitSender', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['decreaseAllowanceExplicitSender', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['burnExplicitSender', [util.ZERO_ADDRESS, 0]],
  ['burnFromExplicitSender', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]]
];
const otherOps = [
  ['transfer', [util.ZERO_ADDRESS, 0]],
  ['approve', [util.ZERO_ADDRESS, 0]],
  ['transferFrom', [util.ZERO_ADDRESS, util.ZERO_ADDRESS, 0]],
  ['increaseAllowance', [util.ZERO_ADDRESS, 0]],
  ['decreaseAllowance', [util.ZERO_ADDRESS, 0]],
  ['burn', [0]],
  ['burnFrom', [util.ZERO_ADDRESS, 0]]
];

function unopgradedTokenBehavior () {
  it('claims not to be upgraded', async function () {
    (await this.token.isUpgraded()).should.be.equal(false);
  });

  it("should return zero address for upgrade token'", async function () {
    (await this.token.upgradedToken()).should.be.equal(util.ZERO_ADDRESS);
  });
}

function proxyTokenBehavior () {
  describe('proxy contract behavior', async function () {
    it('claims to be upgraded', async function () {
      (await this.token.isUpgraded()).should.be.equal(true);
    });

    it("should return zero address for upgrade token'", async function () {
      (await this.token.upgradedToken()).should.be.equal(this.newToken.address);
    });
  });
}

function proxyPausableBehavior () {
  describe('pause', function () {
    it('reverts when token is upgraded', async function () {
      await util.assertRevertsReason(this.token.pause(),
                                     'Token is upgraded. Call pause from new token.');
    });
  });

  describe('unpause', function () {
    it('reverts when token is upgraded', async function () {
      await util.assertRevertsReason(this.token.unpause(),
                                     'Token is upgraded. Call unpause from new token.');
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

contract('TokenX', async function (
  [owner, minter, pauser, otherPauser, burner, whitelistAdmin,
    whitelisted, whitelisted1, blacklisted, blacklisted1,
    blackwhite, blackwhite1, user, user1, ...restAccounts]) {
  // Tokens used during tests
  let token;
  let storage;
  let accesslist;
  let upgradeToken;

  const tokNameOrig = 'USDx';
  const tokNameUpgraded = 'USDxUp';

  const symbolOrig = 'e';
  const symbolUpgraded = 'f';

  beforeEach(async function () {
    accesslist = await Accesslist.new({ from: owner });
    storage = await ExternalERC20Storage.new({ from: owner });

    token = await TokenXMock.new(tokNameOrig, symbolOrig, 10,
                                 accesslist.address, true, storage.address,
                                 0, true, owner, 100, { from: owner });
    upgradeToken = await TokenXMock.new(
      tokNameUpgraded, symbolUpgraded, 20,
      accesslist.address, true, storage.address, token.address, false, 0, 0,
      { from: owner });
    [token, upgradeToken].forEach(async function (f) {
      await f.addMinter(minter, { from: owner });
      await f.addPauser(pauser, { from: owner });
      await f.addBurner(burner, { from: owner });
    });
    await accesslist.addWhitelistAdmin(whitelistAdmin, { from: owner });
    await accesslist.addWhitelisted(owner, { from: owner });
    // Required by the burnFrom test
    await accesslist.addWhitelisted(burner, { from: owner });
    // // Required by the pauser test
    await accesslist.addWhitelisted(otherPauser, { from: owner });
    await accesslist.addWhitelisted(pauser, { from: owner });
    await accesslist.addWhitelisted(whitelisted, { from: owner });
    await accesslist.addWhitelisted(whitelisted1, { from: owner });
    await accesslist.addBlacklisted(blacklisted, { from: owner });
    await accesslist.addBlacklisted(blacklisted1, { from: owner });

    await accesslist.addWhitelisted(blackwhite, { from: owner });
    await accesslist.addWhitelisted(blackwhite1, { from: owner });
    await accesslist.addBlacklisted(blackwhite, { from: owner });
    await accesslist.addBlacklisted(blackwhite1, { from: owner });
  });

  describe('Constructor', function () {
    it('reverts when both upgradedFrom and initialDeployment are set', async function () {
      await util.assertRevertsReason(
        TokenXMock.new(tokNameOrig, symbolOrig, 10,
                       accesslist.address, true, storage.address,
                       0xf00f, true, owner, 100, { from: owner }),
        'Cannot both be upgraded and initial deployment.');
    });

    it('reverts when niether upgradedFrom or initialDeployment are set', async function () {
      await util.assertRevertsReason(
        TokenXMock.new(tokNameOrig, symbolOrig, 10,
                       accesslist.address, true, storage.address,
                       0, false, owner, 100, { from: owner }),
        'Cannot both be upgraded and initial deployment.');
    });

    it('creates when only upgradedFrom is set', async function () {
      TokenXMock.new(tokNameOrig, symbolOrig, 10,
                     accesslist.address, true, storage.address,
                     0xf00f, false, owner, 100, { from: owner });
    });

    it('creates when only initialDeployment is set', async function () {
      TokenXMock.new(tokNameOrig, symbolOrig, 10,
                     accesslist.address, true, storage.address,
                     0, true, owner, 100, { from: owner });
    });
  });

  describe('Pre-upgrade', function () {
    beforeEach(function () {
      this.token = token;
    });

    describe('Original token', function () {
      unopgradedTokenBehavior();
      shouldBehaveLikeERC20PublicAPI(owner, whitelisted, whitelisted1);
      shouldBehaveLikeERC20Mintable(minter, [user]);
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

        await util.assertRevertsReason(token.upgrade(
          upgradeToken.address, { from: owner }),
          'I don\'t own my storage. This will end badly.');
      });

      it('rejects upgrade from non-owner', async function () {
        await util.assertReverts(token.upgrade(
          upgradeToken.address, { from: whitelisted }));
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

      // TODO: Test other query funtions?
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
      shouldBehaveLikeERC20Mintable(minter, [user]);
      shouldBehaveLikeERC20Burnable(owner, 100, [burner]);
      shouldBehaveLikeERC20Pausable(owner, otherPauser,
                                    whitelisted, whitelisted1,
                                    restAccounts);

      ERC20Permissions(owner, whitelisted, user, user1,
                       blacklisted, blacklisted1,
                       blackwhite, blackwhite1);
      identifiesAsNewToken();

      describe('Upgraded token rejects unauthorized for explicit sender functions', function () {
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
      shouldBehaveLikeERC20Mintable(minter, [user]);
      shouldBehaveLikeERC20Burnable(owner, 100, [burner]);
      proxyPausableBehavior();
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
