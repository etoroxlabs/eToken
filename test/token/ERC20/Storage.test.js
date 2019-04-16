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

/* global artifacts, contract, web3 */
/* eslint-env mocha */

const { ZERO_ADDRESS } = require('openzeppelin-solidity/test/helpers/constants');

const Storage = artifacts.require('Storage');
const StorageE = require('./Storage.events.js');

const BigNumber = web3.BigNumber;

const utils = require('./../../utils.js');

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('Storage', function ([_, owner, implementor, anotherAccount, thirdAccount]) {
  beforeEach(async function () {
    this.token = await Storage.new(owner, implementor, { from: owner });
    this.tokenE = StorageE.wrap(this.token);
  });

  describe('initial deployment', function () {
    it('isImplementor should be true initially', async function () {
      (await this.token.isImplementor({ from: implementor })).should.equal(true);
    });

    it('isImplementor for owner should be false', async function () {
      (await this.token.isImplementor({ from: owner })).should.equal(false);
    });

    it('should fail if owner is the zero address', async function () {
      await utils.assertRevertsReason(
        Storage.new(utils.ZERO_ADDRESS, implementor),
        'Owner should not be the zero address');
    });

    it('should fail if implementor is the zero address', async function () {
      await utils.assertRevertsReason(
        Storage.new(owner, utils.ZERO_ADDRESS),
        'Implementor should not be the zero address');
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
    const newBalance = 200;

    describe('when is owner', function () {
      it('should not allow changing balance', async function () {
        await utils.assertRevertsReason(
          this.token.setBalance(anotherAccount, newBalance, { from: owner }),
          'Is not implementor');
      });
    });

    describe('when is implementor', function () {
      it('should allow changing balance', async function () {
        (await this.token.getBalance(anotherAccount)).should.not.be.bignumber.equal(newBalance);
        await this.token.setBalance(anotherAccount, newBalance, { from: implementor });
        (await this.token.getBalance(anotherAccount)).should.be.bignumber.equal(newBalance);
      });
    });

    describe('when is not owner or implementor', function () {
      it('should not allow changing balance', async function () {
        const oldBalance = await this.token.getBalance(anotherAccount);

        oldBalance.should.not.be.bignumber.equal(newBalance);
        await utils.assertRevertsReason(
          this.token.setBalance(anotherAccount, newBalance, { from: thirdAccount }),
          'Is not implementor');
        (await this.token.getBalance(anotherAccount)).should.be.bignumber.equal(oldBalance);
      });
    });
  });

  describe('increaseBalance', function () {
    const initialBalance = 100;
    const increasedValue = 200;

    const totalValue = initialBalance + increasedValue;

    describe('when is owner', function () {
      it('should not allow changing balance', async function () {
        await utils.assertRevertsReason(
          this.token.increaseBalance(anotherAccount, increasedValue, { from: owner }),
          'Is not implementor');
      });
    });

    describe('when is implementor', function () {
      it('should allow increasing balance', async function () {
        await this.token.setBalance(anotherAccount, initialBalance, { from: implementor });
        (await this.token.getBalance(anotherAccount)).should.be.bignumber.equal(initialBalance);
        await this.token.increaseBalance(anotherAccount, increasedValue, { from: implementor });
        (await this.token.getBalance(anotherAccount)).should.be.bignumber.equal(totalValue);
      });
    });

    describe('when is not owner or implementor', function () {
      it('should not allow increasing balance', async function () {
        const oldBalance = await this.token.getBalance(anotherAccount);

        oldBalance.should.not.be.bignumber.equal(totalValue);
        await utils.assertRevertsReason(
          this.token.increaseBalance(anotherAccount, increasedValue, { from: thirdAccount }),
          'Is not implementor');
        (await this.token.getBalance(anotherAccount)).should.be.bignumber.equal(oldBalance);
      });
    });
  });

  describe('decreaseBalance', function () {
    const initialBalance = 100;
    const decreasedValue = 50;

    const totalValue = initialBalance - decreasedValue;

    describe('when is owner', function () {
      it('should not allow changing balance', async function () {
        await utils.assertRevertsReason(
          this.token.decreaseBalance(anotherAccount, decreasedValue, { from: owner }),
          'Is not implementor');
      });
    });

    describe('when is implementor', function () {
      it('should allow decreasing balance', async function () {
        await this.token.setBalance(anotherAccount, initialBalance, { from: implementor });
        (await this.token.getBalance(anotherAccount)).should.be.bignumber.equal(initialBalance);
        await this.token.decreaseBalance(anotherAccount, decreasedValue, { from: implementor });
        (await this.token.getBalance(anotherAccount)).should.be.bignumber.equal(totalValue);
      });
    });

    describe('when is not owner or implementor', function () {
      it('should not allow decreasing balance', async function () {
        const oldBalance = await this.token.getBalance(anotherAccount);

        oldBalance.should.not.be.bignumber.equal(totalValue);
        await utils.assertRevertsReason(
          this.token.decreaseBalance(anotherAccount, decreasedValue, { from: thirdAccount }),
          'Is not implementor');
        (await this.token.getBalance(anotherAccount)).should.be.bignumber.equal(oldBalance);
      });
    });
  });

  describe('setAllowed', function () {
    const newAllowance = 200;

    describe('when is owner', function () {
      it('should not allow changing allowance', async function () {
        await utils.assertRevertsReason(
          this.token.setAllowed(anotherAccount, thirdAccount, newAllowance, { from: owner }),
          'Is not implementor');
      });
    });

    describe('when is implementor', function () {
      it('should allow changing allowance', async function () {
        (await this.token.getAllowed(anotherAccount, thirdAccount)).should.not.be.bignumber.equal(newAllowance);
        await this.token.setAllowed(anotherAccount, thirdAccount, newAllowance, { from: implementor });
        (await this.token.getAllowed(anotherAccount, thirdAccount)).should.be.bignumber.equal(newAllowance);
      });
    });

    describe('when is not owner or implementor', function () {
      it('should not allow changing allowance', async function () {
        const oldAllowance = (await this.token.getAllowed(anotherAccount, thirdAccount));

        oldAllowance.should.not.be.bignumber.equal(newAllowance);
        await utils.assertRevertsReason(
          this.token.setAllowed(anotherAccount, thirdAccount, newAllowance, { from: anotherAccount }),
          'Is not implementor');
        (await this.token.getAllowed(anotherAccount, thirdAccount)).should.be.bignumber.equal(oldAllowance);
      });
    });
  });

  describe('increaseAllowed', function () {
    const initialBalance = 100;
    const increasedValue = 200;

    const totalValue = initialBalance + increasedValue;

    describe('when is owner', function () {
      it('should not allow changing allowance', async function () {
        await utils.assertRevertsReason(
          this.token.increaseAllowed(anotherAccount, thirdAccount,
                                     increasedValue, { from: owner }),
          'Is not implementor');
      });
    });

    describe('when is implementor', function () {
      it('should allow increasing allowance', async function () {
        await this.token.setAllowed(anotherAccount, thirdAccount,
                                    initialBalance, { from: implementor });
        (await this.token.getAllowed(anotherAccount, thirdAccount))
          .should.be.bignumber.equal(initialBalance);

        await this.token.increaseAllowed(anotherAccount, thirdAccount,
                                         increasedValue, { from: implementor });
        (await this.token.getAllowed(anotherAccount, thirdAccount))
          .should.be.bignumber.equal(totalValue);
      });
    });

    describe('when is not owner or implementor', function () {
      it('should not allow increasing allowance', async function () {
        const oldBalance = await this.token.getAllowed(anotherAccount, thirdAccount);

        oldBalance.should.not.be.bignumber.equal(totalValue);
        await utils.assertRevertsReason(
          this.token.increaseAllowed(anotherAccount, thirdAccount,
                                     increasedValue, { from: thirdAccount }),
          'Is not implementor');
        (await this.token.getAllowed(anotherAccount, thirdAccount))
          .should.be.bignumber.equal(oldBalance);
      });
    });
  });

  describe('decreaseAllowed', function () {
    const initialBalance = 100;
    const decreasedValue = 50;

    const totalValue = initialBalance - decreasedValue;

    describe('when is owner', function () {
      it('should not allow changing allowance', async function () {
        await utils.assertRevertsReason(
          this.token.decreaseAllowed(anotherAccount, thirdAccount,
                                     decreasedValue, { from: owner }),
          'Is not implementor');
      });
    });

    describe('when is implementor', function () {
      it('should allow decreasing allowance', async function () {
        await this.token.setAllowed(anotherAccount, thirdAccount,
                                    initialBalance, { from: implementor });
        (await this.token.getAllowed(anotherAccount, thirdAccount))
          .should.be.bignumber.equal(initialBalance);

        await this.token.decreaseAllowed(anotherAccount, thirdAccount,
                                         decreasedValue, { from: implementor });
        (await this.token.getAllowed(anotherAccount, thirdAccount))
          .should.be.bignumber.equal(totalValue);
      });
    });

    describe('when is not owner or implementor', function () {
      it('should not allow decreasing allowance', async function () {
        const oldBalance = await this.token.getAllowed(anotherAccount, thirdAccount);

        oldBalance.should.not.be.bignumber.equal(totalValue);
        await utils.assertRevertsReason(
          this.token.decreaseAllowed(anotherAccount, thirdAccount,
                                     decreasedValue, { from: thirdAccount }),
          'Is not implementor');
        (await this.token.getAllowed(anotherAccount, thirdAccount))
          .should.be.bignumber.equal(oldBalance);
      });
    });
  });

  describe('setTotalSupply', function () {
    const newTotalSupply = 200;

    describe('when is owner', function () {
      it('should not allow changing total supply', async function () {
        await utils.assertRevertsReason(
          this.token.setTotalSupply(newTotalSupply, { from: owner }),
          'Is not implementor');
      });
    });

    describe('when is implementor', function () {
      it('should allow changing total supply', async function () {
        (await this.token.getTotalSupply()).should.not.be.bignumber.equal(newTotalSupply);
        await this.token.setTotalSupply(newTotalSupply, { from: implementor });
        (await this.token.getTotalSupply()).should.be.bignumber.equal(newTotalSupply);
      });
    });

    describe('when is not owner or implementor', function () {
      it('should not allow changing total supply', async function () {
        const oldTotalSupply = await this.token.getTotalSupply();

        oldTotalSupply.should.not.be.bignumber.equal(newTotalSupply);
        await utils.assertRevertsReason(
          this.token.setTotalSupply(newTotalSupply, { from: thirdAccount }),
          'Is not implementor');
        (await this.token.getTotalSupply()).should.be.bignumber.equal(oldTotalSupply);
      });
    });
  });
});
