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

const Storage = artifacts.require('Storage');
const ERC20 = artifacts.require('ERC20');
const ERC20Mock = artifacts.require('ERC20Mock');

const { shouldBehaveLikeERC20 } = require('./behaviors/ERC20.behavior');
const utils = require('../../utils');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('ERC20', function ([_, owner, recipient, anotherAccount]) {
  beforeEach(async function () {
    this.token = await ERC20Mock.new(owner, 100, utils.ZERO_ADDRESS, true);
  });

  describe('At contruction', function () {
    it('should fail if specified external storage and expecting new storage',
       async function () {
         const someAddress = anotherAccount;
         const assertReason = 'Cannot both create external storage and use the provided one.';

         await utils.assertRevertsReason(
           ERC20.new('t', 'test', 4, someAddress, true),
           assertReason);
       }
    );

    it('should fail if not specified external storage and not expecting new storage',
       async function () {
         const assertReason = 'Cannot both create external storage and use the provided one.';
         await utils.assertRevertsReason(
           ERC20.new('t', 'test', 4, utils.ZERO_ADDRESS, false),
           assertReason);
       }
    );
  });

  describe('identity', function () {
    // The expected values for this test are specified in
    // ERC20Mock.sol
    // Tests mainly included for coverage

    it('returns correct name', async function () {
      (await this.token.name()).should.be.equal('test');
    });

    it('returns correct symbol', async function () {
      (await this.token.symbol()).should.be.equal('te');
    });

    it('returns correct number of decimals', async function () {
      (await this.token.decimals()).should.be.bignumber.equal(4);
    });
  });

  shouldBehaveLikeERC20(owner, recipient, anotherAccount);

  describe('When sharing storage', function () {
    beforeEach(async function () {
      this.storage = Storage.at(await this.token.getExternalStorage());
      this.token2 = await ERC20Mock.new(
        owner, 0,
        this.storage.address, false,
        { from: owner }
      );
    });

    it('totalSupply should use external storage', async function () {
      (await this.token.totalSupply()).should.be.bignumber.equal(100);
      (await this.token2.totalSupply()).should.be.bignumber.equal(100);
    });

    it('balanceOf should use external storage', async function () {
      (await this.token.balanceOf(owner)).should.be.bignumber.equal(100);
      (await this.token2.balanceOf(owner)).should.be.bignumber.equal(100);
    });

    it('allowance should use external storage', async function () {
      await this.token.approve(recipient, 50, { from: owner });
      (await this.token.allowance(owner, recipient)).should.be.bignumber.equal(50);
    });

    it('transfer should use external storage', async function () {
      (await this.token.balanceOf(recipient)).should.be.bignumber.equal(0);
      (await this.token2.balanceOf(recipient)).should.be.bignumber.equal(0);

      await this.token.transfer(recipient, 50, { from: owner });

      (await this.token.balanceOf(recipient)).should.be.bignumber.equal(50);
      (await this.token2.balanceOf(recipient)).should.be.bignumber.equal(50);
    });

    it('approve should use external storage', async function () {
      (await this.token.allowance(owner, recipient)).should.be.bignumber.equal(0);
      (await this.token2.allowance(owner, recipient)).should.be.bignumber.equal(0);

      await this.token.approve(recipient, 50, { from: owner });

      (await this.token.allowance(owner, recipient)).should.be.bignumber.equal(50);
      (await this.token2.allowance(owner, recipient)).should.be.bignumber.equal(50);
    });

    it('transferFrom should use external storage', async function () {
      (await this.token.balanceOf(anotherAccount)).should.be.bignumber.equal(0);
      (await this.token2.balanceOf(anotherAccount)).should.be.bignumber.equal(0);

      await this.token.approve(recipient, 100, { from: owner });
      await this.token.transferFrom(owner, anotherAccount, 50, { from: recipient });

      (await this.token.balanceOf(anotherAccount)).should.be.bignumber.equal(50);
      (await this.token2.balanceOf(anotherAccount)).should.be.bignumber.equal(50);
    });

    it('increaseAllowance should use external storage', async function () {
      (await this.token.allowance(owner, recipient)).should.be.bignumber.equal(0);
      (await this.token2.allowance(owner, recipient)).should.be.bignumber.equal(0);

      await this.token.approve(recipient, 50, { from: owner });

      (await this.token.allowance(owner, recipient)).should.be.bignumber.equal(50);
      (await this.token2.allowance(owner, recipient)).should.be.bignumber.equal(50);

      await this.token.increaseAllowance(recipient, 50, { from: owner });

      (await this.token.allowance(owner, recipient)).should.be.bignumber.equal(100);
      (await this.token2.allowance(owner, recipient)).should.be.bignumber.equal(100);
    });

    it('decreaseAllowance should use external storage', async function () {
      (await this.token.allowance(owner, recipient)).should.be.bignumber.equal(0);
      (await this.token2.allowance(owner, recipient)).should.be.bignumber.equal(0);

      await this.token.approve(recipient, 50, { from: owner });

      (await this.token.allowance(owner, recipient)).should.be.bignumber.equal(50);
      (await this.token2.allowance(owner, recipient)).should.be.bignumber.equal(50);

      await this.token.decreaseAllowance(recipient, 50, { from: owner });

      (await this.token.allowance(owner, recipient)).should.be.bignumber.equal(0);
      (await this.token2.allowance(owner, recipient)).should.be.bignumber.equal(0);
    });
  });

  describe('respects explicit senders', function () {
    const spender = recipient;
    const amount = 100;
    describe('approve', function () {
      it('to explicit sender', async function () {
        await this.token.approvePublicTest(
          anotherAccount, spender, amount, { from: owner });
        (await this.token.allowance(anotherAccount, spender, { from: owner }))
          .should.be.bignumber.equal(amount);
        (await this.token.allowance(owner, spender, { from: owner }))
          .should.be.bignumber.equal(0);
      });
    });

    describe('increaseAllowance', function () {
      beforeEach(async function () {
        await this.token.approve(spender, 1, { from: anotherAccount });
        await this.token.approve(spender, 2, { from: owner });
      });

      it('increases allowance of explicit sender', async function () {
        await this.token.increaseAllowancePublicTest(
          anotherAccount, spender, amount, { from: owner });
        (await this.token.allowance(anotherAccount, spender))
          .should.be.bignumber.equal(amount + 1);
        (await this.token.allowance(owner, spender))
          .should.be.bignumber.equal(2);
      });
    });

    describe('decreaseAllowance', function () {
      beforeEach(async function () {
        await this.token.approve(spender, amount + 1, { from: anotherAccount });
        await this.token.approve(spender, amount + 2, { from: owner });
      });

      it('increases allowance of explicit sender', async function () {
        await this.token.decreaseAllowancePublicTest(
          anotherAccount, spender, amount, { from: owner });
        (await this.token.allowance(anotherAccount, spender))
          .should.be.bignumber.equal(1);
        (await this.token.allowance(owner, spender))
          .should.be.bignumber.equal(amount + 2);
      });
    });

    describe('burnFrom', function () {
      const initialSupply = new BigNumber(100);
      const expected = new BigNumber(70);
      const amount = new BigNumber(30);

      const burner = recipient;

      beforeEach('approving', async function () {
        await this.token.mint(anotherAccount, initialSupply);
        await this.token.approve(burner, amount, { from: anotherAccount });
      });

      it('burnsFrom explicit sender', async function () {
        await this.token.burnFromPublicTest(
          burner, anotherAccount, amount, { from: owner });
        (await this.token.balanceOf(anotherAccount))
          .should.be.bignumber.equal(expected);
        (await this.token.balanceOf(owner))
          .should.be.bignumber.equal(initialSupply);
      });
    });

    describe('transferFrom', function () {
      const initialSupply = new BigNumber(100);
      const expectedTo = new BigNumber(130);
      const expectedFrom = new BigNumber(70);
      const amount = new BigNumber(30);

      const spender = recipient;

      beforeEach('approving', async function () {
        await this.token.mint(anotherAccount, initialSupply);
        await this.token.mint(spender, initialSupply);
        await this.token.approve(spender, amount, { from: anotherAccount });
      });

      it('transferFrom explicit sender', async function () {
        await this.token.transferFromPublicTest(
          spender, anotherAccount, owner, amount, { from: owner });
        (await this.token.balanceOf(anotherAccount))
          .should.be.bignumber.equal(expectedFrom);
        (await this.token.balanceOf(owner))
          .should.be.bignumber.equal(expectedTo);
        (await this.token.balanceOf(spender))
          .should.be.bignumber.equal(initialSupply);
      });
    });
  });
});
