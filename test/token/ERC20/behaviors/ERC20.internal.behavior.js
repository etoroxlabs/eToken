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

function shouldBehaveLikeERC20InternalAPI (owner, recipient, anotherAccount) {
  describe('total supply', function () {
    it('returns the total amount of tokens', async function () {
      (await this.token.totalSupply()).should.be.bignumber.equal(100);
    });
  });

  describe('_mint', function () {
    const initialSupply = new BigNumber(100);
    const amount = new BigNumber(50);

    it('rejects a null account', async function () {
      await shouldFail.reverting(this.token.mint(ZERO_ADDRESS, amount));
    });

    describe('for a non null account', function () {
      beforeEach('minting', async function () {
        const res = await this.token.mint(recipient, amount);
        const { logs } = res;
        this.logs = logs;
      });

      it('increments totalSupply', async function () {
        const expectedSupply = initialSupply.plus(amount);
        (await this.token.totalSupply()).should.be.bignumber.equal(expectedSupply);
      });

      it('increments recipient balance', async function () {
        (await this.token.balanceOf(recipient)).should.be.bignumber.equal(amount);
      });

      it('emits Transfer event', async function () {
        const event = expectEvent.inLogs(this.logs, 'Transfer', {
          from: ZERO_ADDRESS,
          to: recipient
        });

        event.args.value.should.be.bignumber.equal(amount);
      });
    });
  });

  describe('_burn', function () {
    const initialSupply = new BigNumber(100);

    it('rejects a null account', async function () {
      await shouldFail.reverting(this.token.burn(ZERO_ADDRESS, 1));
    });

    describe('for a non null account', function () {
      it('rejects burning more than balance', async function () {
        await shouldFail.reverting(this.token.burn(owner, initialSupply.plus(1)));
      });

      const describeBurn = function (description, amount) {
        describe(description, function () {
          beforeEach('burning', async function () {
            const { logs } = await this.token.burn(owner, amount);
            this.logs = logs;
          });

          it('decrements totalSupply', async function () {
            const expectedSupply = initialSupply.minus(amount);
            (await this.token.totalSupply()).should.be.bignumber.equal(expectedSupply);
          });

          it('decrements owner balance', async function () {
            const expectedBalance = initialSupply.minus(amount);
            (await this.token.balanceOf(owner)).should.be.bignumber.equal(expectedBalance);
          });

          it('emits Transfer event', async function () {
            const event = expectEvent.inLogs(this.logs, 'Transfer', {
              from: owner,
              to: ZERO_ADDRESS
            });

            event.args.value.should.be.bignumber.equal(amount);
          });
        });
      };

      describeBurn('for entire balance', initialSupply);
      describeBurn('for less amount than balance', initialSupply.sub(1));
    });
  });

  describe('_burnFrom', function () {
    const initialSupply = new BigNumber(100);
    const allowance = new BigNumber(70);

    const spender = anotherAccount;

    beforeEach('approving', async function () {
      await this.token.approve(spender, allowance, { from: owner });
    });

    it('rejects a null account', async function () {
      await shouldFail.reverting(this.token.burnFrom(ZERO_ADDRESS, 1));
    });

    describe('for a non null account', function () {
      it('rejects burning more than allowance', async function () {
        await shouldFail.reverting(this.token.burnFrom(owner, allowance.plus(1)));
      });

      it('rejects burning more than balance', async function () {
        await shouldFail.reverting(this.token.burnFrom(owner, initialSupply.plus(1)));
      });

      const describeBurnFrom = function (description, amount) {
        describe(description, function () {
          beforeEach('burning', async function () {
            const { logs } = await this.token.burnFrom(owner, amount, { from: spender });
            this.logs = logs;
          });

          it('decrements totalSupply', async function () {
            const expectedSupply = initialSupply.minus(amount);
            (await this.token.totalSupply()).should.be.bignumber.equal(expectedSupply);
          });

          it('decrements owner balance', async function () {
            const expectedBalance = initialSupply.minus(amount);
            (await this.token.balanceOf(owner)).should.be.bignumber.equal(expectedBalance);
          });

          it('decrements spender allowance', async function () {
            const expectedAllowance = allowance.minus(amount);
            (await this.token.allowance(owner, spender)).should.be.bignumber.equal(expectedAllowance);
          });

          it('emits Transfer event', async function () {
            const event = expectEvent.inLogs(this.logs, 'Transfer', {
              from: owner,
              to: ZERO_ADDRESS
            });

            event.args.value.should.be.bignumber.equal(amount);
          });
        });
      };

      describeBurnFrom('for entire allowance', allowance);
      describeBurnFrom('for less amount than allowance', allowance.sub(1));
    });
  });
}

module.exports = {
  shouldBehaveLikeERC20InternalAPI
};
