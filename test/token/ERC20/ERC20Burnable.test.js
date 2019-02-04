/* global artifacts, contract */
/* eslint-env mocha */

const Storage = artifacts.require('Storage');
const ERC20BurnableMock = artifacts.require('ERC20BurnableMock');

const { shouldBehaveLikeERC20Burnable } = require('./behaviors/ERC20Burnable.behavior');
const utils = require('../../utils');

contract('ERC20Burnable', function ([_, owner, spender, ...otherAccounts]) {
  const initialBalance = 1000;

  beforeEach(async function () {
    this.token = await ERC20BurnableMock.new(owner, initialBalance, utils.ZERO_ADDRESS, true, { from: owner });
  });

  shouldBehaveLikeERC20Burnable(owner, initialBalance, otherAccounts);

  describe('When sharing storage', function () {
    beforeEach(async function () {
      this.storage = Storage.at(await this.token.getExternalStorage());
      this.token2 = await ERC20BurnableMock.new(
        owner, 0,
        this.storage.address,
        false,
        { from: owner }
      );
    });

    it('burn should use external storage', async function () {
      (await this.token.totalSupply()).should.be.bignumber.equal(initialBalance);
      (await this.token2.totalSupply()).should.be.bignumber.equal(initialBalance);

      await this.token.burn(initialBalance, { from: owner });

      (await this.token.totalSupply()).should.be.bignumber.equal(0);
      (await this.token2.totalSupply()).should.be.bignumber.equal(0);
    });

    it('burnFrom should use external storage', async function () {
      (await this.token.totalSupply()).should.be.bignumber.equal(initialBalance);
      (await this.token2.totalSupply()).should.be.bignumber.equal(initialBalance);

      await this.token.approve(spender, initialBalance, { from: owner });
      await this.token.burnFrom(owner, initialBalance, { from: spender });

      (await this.token.totalSupply()).should.be.bignumber.equal(0);
      (await this.token2.totalSupply()).should.be.bignumber.equal(0);
    });
  });
});
