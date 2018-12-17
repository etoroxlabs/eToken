/* global artifacts, contract */
/* eslint-env mocha */

const ExternalERC20Storage = artifacts.require('ExternalERC20Storage');
const ExternalERC20 = artifacts.require('ExternalERC20');

const { shouldBehaveLikeERC20Mintable } = require('./behaviors/ERC20Mintable.behavior');
const ExternalERC20MintableMock = artifacts.require('ExternalERC20MintableMock');
const { shouldBehaveLikePublicRole } = require('../../roles/PublicRole.behavior');

contract('ExternalERC20Mintable', function ([_, minter, otherMinter, ...otherAccounts]) {
  beforeEach(async function () {
    this.token = await ExternalERC20MintableMock.new({ from: minter });
  });

  describe('minter role', function () {
    beforeEach(async function () {
      this.contract = this.token;
      await this.contract.addMinter(otherMinter, { from: minter });
    });

    shouldBehaveLikePublicRole(minter, otherMinter, otherAccounts, 'minter');
  });

  shouldBehaveLikeERC20Mintable(minter, otherAccounts);

  describe('When sharing storage', function () {
    beforeEach(async function () {
      this.storage = ExternalERC20Storage.at(await this.token._externalERC20Storage());
      this.token2 = await ExternalERC20.new(
        this.storage.address,
        { from: minter }
      );
    });

    it('minting should use external storage', async function () {
      (await this.token.totalSupply()).should.be.bignumber.equal(0);
      (await this.token2.totalSupply()).should.be.bignumber.equal(0);

      await this.token.mint(minter, 100, { from: minter });

      (await this.token.totalSupply()).should.be.bignumber.equal(100);
      (await this.token2.totalSupply()).should.be.bignumber.equal(100);
    });
  });
});
