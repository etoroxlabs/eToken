/* global artifacts, contract */
/* eslint-env mocha */

const ExternalERC20Storage = artifacts.require('ExternalERC20Storage');
const ExternalERC20 = artifacts.require('ExternalERC20');

const { shouldBehaveLikeERC20Mintable } = require('./behaviors/ERC20Mintable.behavior');
const ExternalERC20MintableMock = artifacts.require('ExternalERC20MintableMock');
const { shouldBehaveLikePublicRole } = require('../../roles/behaviors/PublicRole.behavior');

contract('ExternalERC20Mintable', function ([_, minter, otherMinter, ...otherAccounts]) {
  const mintingRecipientAccount = '0x000000000000000000000000000000000000d00f';
  beforeEach(async function () {
    this.token = await ExternalERC20MintableMock.new(mintingRecipientAccount, { from: minter });
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
      this.storage = ExternalERC20Storage.at(await this.token._externalERC20Storage());
      this.token2 = await ExternalERC20.new(
        this.storage.address,
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
      (await this.token.getMintingRecipientAccount()).should.be.equal(mintingRecipientAccount);
    });

    it('should return correct address when changed', async function () {
      const newAccount = '0x000000000000000000000000000000000000dddd';
      await this.token.changeMintingRecipient(newAccount, {from: minter});
      (await this.token.getMintingRecipientAccount()).should.be.equal(newAccount);
    });
  });
});
