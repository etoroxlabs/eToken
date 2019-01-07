/* global artifacts, contract, web3 */
/* eslint-env mocha */

const { ZERO_ADDRESS } = require('openzeppelin-solidity/test/helpers/constants');

const ExternalERC20Storage = artifacts.require('ExternalERC20Storage');
const ExternalERC20StorageE = require('./ExternalERC20Storage.events.js');

const BigNumber = web3.BigNumber;

const utils = require('./../../utils.js');

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('ExternalERC20Storage', function ([_, owner, implementor, anotherAccount, thirdAccount]) {
  beforeEach(async function () {
    this.token = await ExternalERC20Storage.new({ from: owner });
    this.tokenE = ExternalERC20StorageE.wrap(this.token);
    await this.token.latchInitialImplementor({ from: implementor });
  });

  describe('setting initial implementor', function () {
    beforeEach(async function () {
      this.otherStorage = await ExternalERC20Storage.new({ from: owner });
      this.otherStorageE = ExternalERC20StorageE.wrap(this.otherStorage);
    });

    it('hasImplementor should be false initially', async function () {
      (await this.otherStorage.hasImplementor()).should.equal(false);
    });

    it('isImplementor should be false initially', async function () {
      (await this.otherStorage.isImplementor({ from: owner })).should.equal(false);
    });

    it('hasImplementor should is true after setting implementor', async function () {
      (await this.otherStorage.hasImplementor()).should.equal(false);
      this.otherStorage.latchInitialImplementor({ from: anotherAccount });
      (await this.otherStorage.hasImplementor()).should.equal(true);
    });

    it('latchInitialImplementor sets isImplementor correctly', async function () {
      (await this.otherStorage.isImplementor({ from: anotherAccount })).should.equal(false);
      this.otherStorage.latchInitialImplementor({ from: anotherAccount });
      (await this.otherStorage.isImplementor({ from: anotherAccount })).should.equal(true);
    });

    it('reverts when iplementor already exists', async function () {
      // Note: Uses this.token initialized in parent beforeEach
      await utils.assertRevertsReason(this.token.latchInitialImplementor({ from: owner }),
                                      'Storage implementor is already set');
    });

    it('Should emit initial implementor event', async function () {
      await this.otherStorageE.latchInitialImplementor(implementor, { from: implementor });
    });
  });

  describe('transferring implementor', function () {
    const commonOwnerImplementorTests = function (ownerOrImplementorAddress, newImplementor) {
      it('should allow transferring of implementor', async function () {
        (await this.token.isImplementor({ from: newImplementor })).should.equal(false);
        await this.token.transferImplementor(newImplementor, { from: ownerOrImplementorAddress });
        (await this.token.isImplementor({ from: newImplementor })).should.equal(true);
      });

      it('should require non-zero address when transferring implementor', async function () {
        await utils.assertRevertsReason(
          this.token.transferImplementor(ZERO_ADDRESS, { from: ownerOrImplementorAddress }),
          'Expected a non-zero address');
      });

      it('should emit implementor transferred event', async function () {
        await this.tokenE.transferImplementor(
          anotherAccount, implementor, { from: ownerOrImplementorAddress });
      });

      it('should revert when transferring to existing implementor', async function () {
        await utils.assertRevertsReason(
          this.token.transferImplementor(implementor, { from: ownerOrImplementorAddress }),
          'Cannot transfer to same implementor as existing');
      });
    };

    describe('when is owner', function () {
      it('should be owner', async function () {
        (await this.token.isOwner({ from: owner })).should.equal(true);
      });

      it('should still be owner after transferring implementor', async function () {
        (await this.token.isOwner({ from: owner })).should.equal(true);

        (await this.token.isImplementor({ from: anotherAccount })).should.equal(false);
        await this.token.transferImplementor(anotherAccount, { from: owner });
        (await this.token.isImplementor({ from: anotherAccount })).should.equal(true);

        (await this.token.isOwner({ from: owner })).should.equal(true);
      });

      commonOwnerImplementorTests(owner, anotherAccount);
    });

    describe('when is implementor', function () {
      it('should allow transferring to new implementor', async function () {
        (await this.token.isImplementor({ from: implementor })).should.equal(true);
        await this.token.transferImplementor(thirdAccount, { from: implementor });
        (await this.token.isImplementor({ from: implementor })).should.equal(false);
        (await this.token.isImplementor({ from: thirdAccount })).should.equal(true);
      });

      commonOwnerImplementorTests(implementor, anotherAccount);
    });

    describe('when is not owner or implementor', function () {
      it('should not allow transfer implementor', async function () {
        await utils.assertRevertsReason(this.token.transferImplementor(anotherAccount, { from: thirdAccount }),
                                        'Is not implementor or owner');
        (await this.token.isImplementor({ from: anotherAccount })).should.equal(false);
      });
    });
  });

  describe('setBalance', function () {
    const commonOwnerImplementorTests = function (ownerOrImplementorAddress) {
      it('should allow changing balance', async function () {
        const newBalance = 200;

        (await this.token.balances(anotherAccount)).should.not.be.bignumber.equal(newBalance);
        await this.token.setBalance(anotherAccount, newBalance, { from: ownerOrImplementorAddress });
        (await this.token.balances(anotherAccount)).should.be.bignumber.equal(newBalance);
      });
    };

    describe('when is owner', function () {
      commonOwnerImplementorTests(owner);
    });

    describe('when is implementor', function () {
      commonOwnerImplementorTests(implementor);
    });

    describe('when is not owner or implementor', function () {
      it('should not allow changing balance', async function () {
        const newBalance = 200;
        const oldBalance = await this.token.balances(anotherAccount);

        oldBalance.should.not.be.bignumber.equal(newBalance);
        await utils.assertRevertsReason(
          this.token.setBalance(anotherAccount, newBalance, { from: thirdAccount }),
          'Is not implementor or owner');
        (await this.token.balances(anotherAccount)).should.be.bignumber.equal(oldBalance);
      });
    });
  });

  describe('setAllowed', function () {
    const commonOwnerImplementorTests = function (ownerOrImplementorAddress) {
      it('should allow changing allowance', async function () {
        const newAllowance = 200;

        (await this.token.allowed(anotherAccount, thirdAccount)).should.not.be.bignumber.equal(newAllowance);
        await this.token.setAllowed(anotherAccount, thirdAccount, newAllowance, { from: ownerOrImplementorAddress });
        (await this.token.allowed(anotherAccount, thirdAccount)).should.be.bignumber.equal(newAllowance);
      });
    };

    describe('when is owner', function () {
      commonOwnerImplementorTests(owner);
    });

    describe('when is implementor', function () {
      commonOwnerImplementorTests(implementor);
    });

    describe('when is not owner or implementor', function () {
      it('should not allow changing balance', async function () {
        const newAllowance = 200;
        const oldAllowance = (await this.token.allowed(anotherAccount, thirdAccount));

        oldAllowance.should.not.be.bignumber.equal(newAllowance);
        await utils.assertRevertsReason(
          this.token.setAllowed(anotherAccount, thirdAccount, newAllowance, { from: anotherAccount }),
          'Is not implementor or owner');
        (await this.token.allowed(anotherAccount, thirdAccount)).should.be.bignumber.equal(oldAllowance);
      });
    });
  });

  describe('setTotalSupply', function () {
    const commonOwnerImplementorTests = function (ownerOrImplementorAddress) {
      it('should allow changing total supply', async function () {
        const newTotalSupply = 200;

        (await this.token.totalSupply()).should.not.be.bignumber.equal(newTotalSupply);
        await this.token.setTotalSupply(newTotalSupply, { from: ownerOrImplementorAddress });
        (await this.token.totalSupply()).should.be.bignumber.equal(newTotalSupply);
      });
    };

    describe('when is owner', function () {
      commonOwnerImplementorTests(owner);
    });

    describe('when is implementor', function () {
      commonOwnerImplementorTests(implementor);
    });

    describe('when is not owner or implementor', function () {
      it('should not allow changing balance', async function () {
        const newTotalSupply = 200;
        const oldTotalSupply = await this.token.totalSupply();

        oldTotalSupply.should.not.be.bignumber.equal(newTotalSupply);
        await utils.assertRevertsReason(
          this.token.setTotalSupply(newTotalSupply, { from: thirdAccount }),
          'Is not implementor or owner');
        (await this.token.totalSupply()).should.be.bignumber.equal(oldTotalSupply);
      });
    });
  });
});
