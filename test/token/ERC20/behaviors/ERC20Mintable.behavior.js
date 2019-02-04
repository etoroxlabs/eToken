/* global web3 */
/* eslint-env mocha */

const shouldFail = require('openzeppelin-solidity/test/helpers/shouldFail');
const expectEvent = require('openzeppelin-solidity/test/helpers/expectEvent');
const { ZERO_ADDRESS } = require('openzeppelin-solidity/test/helpers/constants');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

function shouldBehaveLikeERC20Mintable (owner, minter, [anyone], mintingRecip) {
  function shouldMint (amount, recip) {
    const from = minter;
    beforeEach(async function () {
      ({ logs: this.logs } = await this.token.mint(recip, amount, { from }));
    });

    it('mints the requested amount', async function () {
      (await this.token.balanceOf(recip)).should.be.bignumber.equal(amount);
    });

    it('emits a mint and a transfer event', async function () {
      expectEvent.inLogs(this.logs, 'Transfer', {
        from: ZERO_ADDRESS,
        to: recip,
        value: amount
      });
    });
  }

  describe('as a mintable token', function () {
    describe('mint', function () {
      const amount = 100;

      context('when the sender has minting permission', function () {
        context('for a zero amount', function () {
          shouldMint(0, mintingRecip);
        });

        context('for a non-zero amount', function () {
          shouldMint(amount, mintingRecip);
        });
      });

      context('when minting to a disallowed recipient', function () {
        it('reverts', async function () {
          await shouldFail.reverting(
            this.token.mint(anyone, amount, { from: minter }));
        });
      });

      context('when changing recipient to zero address', function () {
        it('reverts', async function () {
          await shouldFail.reverting(
            this.token.changeMintingRecipient(0, { from: minter }));
        });
      });

      context('when sender is not owner', function () {
        it('reverts', async function () {
          await shouldFail.reverting(
            this.token.changeMintingRecipient(anyone, { from: anyone }));
        });
      });

      it('reverts when changing recipient to zero addr ', async function () {
        await shouldFail.reverting(
          this.token.changeMintingRecipient(0, { from: minter }));
      });

      it('returns the correct minting recipient', async function () {
        (await this.token.getMintingRecipient())
          .should.be.bignumber.equal(mintingRecip);
      });

      context('when changing minting recipient', async function () {
        const newMintingRecip = '0x000000000000000000000000000000000000d00e';

        beforeEach(async function () {
          ({ logs: this.logs2 } =
           await this.token.changeMintingRecipient(newMintingRecip, { from: owner }));
        });

        shouldMint(amount, newMintingRecip);

        describe('when minting to previous recipient', function () {
          it('reverts', async function () {
            await shouldFail.reverting(
              this.token.mint(mintingRecip, amount, { from: minter }));
          });
        });

        it('emits a minting recipient changed event', async function () {
          expectEvent.inLogs(this.logs2, 'MintingRecipientAccountChanged', {
            prev: mintingRecip,
            next: newMintingRecip
          });
        });
      });

      context('when the sender doesn\'t have minting permission', function () {
        const from = anyone;

        it('reverts', async function () {
          await shouldFail.reverting(this.token.mint(anyone, amount, { from }));
        });
      });
    });
  });
}

module.exports = {
  shouldBehaveLikeERC20Mintable
};
