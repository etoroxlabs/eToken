const ExternalERC20Storage = artifacts.require('ExternalERC20Storage');
const ExternalERC20 = artifacts.require('ExternalERC20');
const ExternalERC20Mock = artifacts.require('ExternalERC20Mock');

const { shouldBehaveLikeERC20Burnable } = require('./behaviors/ERC20Burnable.behavior');
const ExternalERC20BurnableMock = artifacts.require('ExternalERC20BurnableMock');

contract('ExternalERC20Burnable', function ([_, owner, spender, ...otherAccounts]) {
  const initialBalance = 1000;

  beforeEach(async function () {
    this.token = await ExternalERC20BurnableMock.new(owner, initialBalance, { from: owner });
  });

  shouldBehaveLikeERC20Burnable(owner, initialBalance, otherAccounts);

  describe('When sharing storage', function() {
    beforeEach(async function () {
      this.storage = ExternalERC20Storage.at(await this.token._externalERC20Storage());
      this.token2 = await ExternalERC20.new(
        this.storage.address,
        {from: owner}
      );
    });

    it("burn should use external storage", async function() {
      (await this.token.totalSupply()).should.be.bignumber.equal(initialBalance);
      (await this.token2.totalSupply()).should.be.bignumber.equal(initialBalance);

      await this.token.burn(initialBalance, {from: owner});

      (await this.token.totalSupply()).should.be.bignumber.equal(0);
      (await this.token2.totalSupply()).should.be.bignumber.equal(0);
    });

    it("burnFrom should use external storage", async function() {
      (await this.token.totalSupply()).should.be.bignumber.equal(initialBalance);
      (await this.token2.totalSupply()).should.be.bignumber.equal(initialBalance);

      await this.token.approve(spender, initialBalance, {from: owner});
      await this.token.burnFrom(owner, initialBalance, {from: spender});

      (await this.token.totalSupply()).should.be.bignumber.equal(0);
      (await this.token2.totalSupply()).should.be.bignumber.equal(0);
    });
  });
});
