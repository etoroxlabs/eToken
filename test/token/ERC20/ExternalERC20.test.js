/* global artifacts, contract, web3 */
/* eslint-env mocha */

const ExternalERC20Storage = artifacts.require('ExternalERC20Storage');
const ExternalERC20 = artifacts.require('ExternalERC20');
const ExternalERC20Mock = artifacts.require('ExternalERC20Mock');

const { shouldBehaveLikeERC20 } = require('./behaviors/ERC20.behavior');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('ExternalERC20', function ([_, owner, recipient, anotherAccount]) {
  beforeEach(async function () {
    this.token = await ExternalERC20Mock.new(owner, 100);
  });

  shouldBehaveLikeERC20(owner, recipient, anotherAccount);

  describe('When sharing storage', function () {
    beforeEach(async function () {
      this.storage = ExternalERC20Storage.at(await this.token._externalERC20Storage());
      this.token2 = await ExternalERC20.new(
        this.storage.address,
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

      // await this.storage.setImplementor(this.token2.address, {from: owner});
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
