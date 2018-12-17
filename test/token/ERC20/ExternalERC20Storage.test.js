/* global artifacts, contract, web3 */
/* eslint-env mocha */

const shouldFail = require('openzeppelin-solidity/test/helpers/shouldFail');
// const expectEvent = require('../../../helpers/expectEvent');
const { ZERO_ADDRESS } = require('openzeppelin-solidity/test/helpers/constants');

const ExternalERC20Storage = artifacts.require('ExternalERC20Storage');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('ExternalERC20Storage', function ([_, owner, implementor, anotherAccount, thirdAccount]) {
  beforeEach(async function () {
    this.token = await ExternalERC20Storage.new({ from: owner });
  });

  describe('transferring implementor', function () {
    const commonOwnerImplementorTests = function (ownerOrImplementorAddress) {
      it('should allow transferring of implementor', async function () {
        (await this.token.isImplementor({ from: anotherAccount })).should.equal(false);
        await this.token.transferImplementor(anotherAccount, { from: ownerOrImplementorAddress });
        (await this.token.isImplementor({ from: anotherAccount })).should.equal(true);
      });

      it('should require non-zero address when transferring implementor', async function () {
        await shouldFail.reverting(this.token.transferImplementor(ZERO_ADDRESS, { from: ownerOrImplementorAddress }));
      });
    };

    describe('when is owner', function () {
      it('should be owner', async function () {
        (await this.token.isOwner({ from: owner })).should.equal(true);
      });

      it('should still be owner when transferring implementor', async function () {
        (await this.token.isOwner({ from: owner })).should.equal(true);

        (await this.token.isImplementor({ from: anotherAccount })).should.equal(false);
        await this.token.transferImplementor(anotherAccount, { from: owner });
        (await this.token.isImplementor({ from: anotherAccount })).should.equal(true);

        (await this.token.isOwner({ from: owner })).should.equal(true);
      });

      commonOwnerImplementorTests(owner);
    });

    describe('when is implementor', function () {
      beforeEach(async function () {
        await this.token.transferImplementor(implementor, { from: owner });
      });

      it('should allow transferring to new implementor', async function () {
        await this.token.transferImplementor(implementor, { from: owner });
        (await this.token.isImplementor({ from: implementor })).should.equal(true);

        await this.token.transferImplementor(anotherAccount, { from: implementor });
        (await this.token.isImplementor({ from: implementor })).should.equal(false);
        (await this.token.isImplementor({ from: anotherAccount })).should.equal(true);
      });

      commonOwnerImplementorTests(implementor);
    });

    describe('when is not owner or implementor', function () {
      it('should not allow transfer implementor', async function () {
        await shouldFail.reverting(this.token.transferImplementor(anotherAccount, { from: thirdAccount }));
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
      beforeEach(async function () {
        await this.token.transferImplementor(implementor, { from: owner });
      });

      commonOwnerImplementorTests(implementor);
    });

    describe('when is not owner or implementor', function () {
      it('should not allow changing balance', async function () {
        const newBalance = 200;
        const oldBalance = await this.token.balances(anotherAccount);

        oldBalance.should.not.be.bignumber.equal(newBalance);
        await shouldFail.reverting(this.token.setBalance(anotherAccount, newBalance, { from: thirdAccount }));
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
      beforeEach(async function () {
        await this.token.transferImplementor(implementor, { from: owner });
      });

      commonOwnerImplementorTests(implementor);
    });

    describe('when is not owner or implementor', function () {
      it('should not allow changing balance', async function () {
        const newAllowance = 200;
        const oldAllowance = (await this.token.allowed(anotherAccount, thirdAccount));

        oldAllowance.should.not.be.bignumber.equal(newAllowance);
        await shouldFail.reverting(
          this.token.setAllowed(anotherAccount, thirdAccount, newAllowance, { from: anotherAccount })
        );
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
      beforeEach(async function () {
        await this.token.transferImplementor(implementor, { from: owner });
      });

      commonOwnerImplementorTests(implementor);
    });

    describe('when is not owner or implementor', function () {
      it('should not allow changing balance', async function () {
        const newTotalSupply = 200;
        const oldTotalSupply = await this.token.totalSupply();

        oldTotalSupply.should.not.be.bignumber.equal(newTotalSupply);
        await shouldFail.reverting(this.token.setTotalSupply(newTotalSupply, { from: thirdAccount }));
        (await this.token.totalSupply()).should.be.bignumber.equal(oldTotalSupply);
      });
    });
  });
});
