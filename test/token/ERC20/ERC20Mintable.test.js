/* global artifacts, contract */
/* eslint-env mocha */

const Storage = artifacts.require('Storage');
const ERC20Mock = artifacts.require('ERC20Mock');

const { shouldBehaveLikeERC20Mintable } = require('./behaviors/ERC20Mintable.behavior');
const ERC20MintableMock = artifacts.require('ERC20MintableMock');
const { shouldBehaveLikePublicRole } = require('../access/roles/behaviors/PublicRole.behavior');

contract('ERC20MockMintable', function ([_, minter, otherMinter, ...otherAccounts]) {
  const mintingRecipientAccount = '0x000000000000000000000000000000000000d00f';
  beforeEach(async function () {
    this.token = await ERC20MintableMock.new(mintingRecipientAccount, { from: minter });
    this.token.addMinter(minter, { from: minter });
  });

  describe('minter role', function () {
    beforeEach(async function () {
      this.contract = this.token;
      this.token.addMinter(otherMinter, { from: minter });
    });

    shouldBehaveLikePublicRole(minter, otherMinter, otherAccounts, 'minter');
  });

  shouldBehaveLikeERC20Mintable(minter, minter, otherAccounts, mintingRecipientAccount);

  describe('When sharing storage', function () {
    beforeEach(async function () {
      this.storage = Storage.at(await this.token.getExternalStorage());
      this.token2 = await ERC20Mock.new(
        minter, 0, this.storage.address,
        false,
        { from: minter }
      );
    });

    it('minting should use external storage', async function () {
      (await this.token.totalSupply()).should.be.bignumber.equal(0);
      (await this.token2.totalSupply()).should.be.bignumber.equal(0);

      await this.token.mint(mintingRecipientAccount, 100, { from: minter });

      (await this.token.totalSupply()).should.be.bignumber.equal(100);
      (await this.token2.totalSupply()).should.be.bignumber.equal(100);
    });
  });

  describe('When retrieving minting recipient account', function () {
    it('should return correct address when not changed', async function () {
      (await this.token.getMintingRecipient()).should.be.equal(mintingRecipientAccount);
    });

    it('should return correct address when changed', async function () {
      const newAccount = '0x000000000000000000000000000000000000dddd';
      await this.token.changeMintingRecipient(newAccount, { from: minter });
      (await this.token.getMintingRecipient()).should.be.equal(newAccount);
    });
  });
});
