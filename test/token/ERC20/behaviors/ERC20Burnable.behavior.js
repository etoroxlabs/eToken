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

/* global web3 */
/* eslint-env mocha */

const shouldFail = require('openzeppelin-solidity/test/helpers/shouldFail');
const expectEvent = require('openzeppelin-solidity/test/helpers/expectEvent');
const { ZERO_ADDRESS } = require('openzeppelin-solidity/test/helpers/constants');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

function shouldBehaveLikeERC20Burnable (owner, initialBalance, [burner]) {
  describe('burn', function () {
    describe('when the given amount is not greater than balance of the sender', function () {
      context('for a zero amount', function () {
        shouldBurn(0);
      });

      context('for a non-zero amount', function () {
        shouldBurn(100);
      });

      function shouldBurn (amount) {
        beforeEach(async function () {
          ({ logs: this.logs } = await this.token.burn(amount, { from: owner }));
        });

        it('burns the requested amount', async function () {
          (await this.token.balanceOf(owner)).should.be.bignumber.equal(initialBalance - amount);
        });

        it('emits a transfer event', async function () {
          expectEvent.inLogs(this.logs, 'Transfer', {
            from: owner,
            to: ZERO_ADDRESS,
            value: amount
          });
        });
      }
    });

    describe('when the given amount is greater than the balance of the sender', function () {
      const amount = initialBalance + 1;

      it('reverts', async function () {
        await shouldFail.reverting(this.token.burn(amount, { from: owner }));
      });
    });
  });

  describe('burnFrom', function () {
    describe('on success', function () {
      context('for a zero amount', function () {
        shouldBurnFrom(0);
      });

      context('for a non-zero amount', function () {
        shouldBurnFrom(100);
      });

      function shouldBurnFrom (amount) {
        const originalAllowance = amount * 3;

        beforeEach(async function () {
          await this.token.approve(burner, originalAllowance, { from: owner });
          const { logs } = await this.token.burnFrom(owner, amount, { from: burner });
          this.logs = logs;
        });

        it('burns the requested amount', async function () {
          (await this.token.balanceOf(owner)).should.be.bignumber.equal(initialBalance - amount);
        });

        it('decrements allowance', async function () {
          (await this.token.allowance(owner, burner)).should.be.bignumber.equal(originalAllowance - amount);
        });

        it('emits a transfer event', async function () {
          expectEvent.inLogs(this.logs, 'Transfer', {
            from: owner,
            to: ZERO_ADDRESS,
            value: amount
          });
        });

        it('emits an approval event', async function () {
          expectEvent.inLogs(this.logs, 'Approval', {
            owner: owner,
            spender: burner,
            value: originalAllowance - amount
          });
        });
      }
    });

    describe('when the given amount is greater than the balance of the sender', function () {
      const amount = initialBalance + 1;
      it('reverts', async function () {
        await this.token.approve(burner, amount, { from: owner });
        await shouldFail.reverting(this.token.burnFrom(owner, amount, { from: burner }));
      });
    });

    describe('when the given amount is greater than the allowance', function () {
      const amount = 100;
      it('reverts', async function () {
        await this.token.approve(burner, amount - 1, { from: owner });
        await shouldFail.reverting(this.token.burnFrom(owner, amount, { from: burner }));
      });
    });
  });
}

module.exports = {
  shouldBehaveLikeERC20Burnable
};
