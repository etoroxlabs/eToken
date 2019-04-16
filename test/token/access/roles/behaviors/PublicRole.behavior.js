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

/* eslint-env mocha */

const shouldFail = require('openzeppelin-solidity/test/helpers/shouldFail');
const { ZERO_ADDRESS } = require('openzeppelin-solidity/test/helpers/constants');
const expectEvent = require('openzeppelin-solidity/test/helpers/expectEvent');

require('chai')
  .should();

function capitalize (str) {
  return str.replace(/\b\w/g, l => l.toUpperCase());
}

function shouldBehaveLikePublicRole (authorized, otherAuthorized, [anyone], rolename) {
  rolename = capitalize(rolename);

  describe('should behave like public role', function () {
    beforeEach('check preconditions', async function () {
      (await this.contract[`is${rolename}`](authorized)).should.equal(true);
      (await this.contract[`is${rolename}`](otherAuthorized)).should.equal(true);
      (await this.contract[`is${rolename}`](anyone)).should.equal(false);
    });

    it('reverts when querying roles for the null account', async function () {
      await shouldFail.reverting(this.contract[`is${rolename}`](ZERO_ADDRESS));
    });

    describe('access control', function () {
      context('from authorized account', function () {
        const from = authorized;

        it('allows address via implicit sender address', async function () {
          await this.contract[`only${rolename}Mock`]({ from });
        });

        it('allows access via explicit address', async function () {
          await this.contract[`require${rolename}Mock`](from, { from });
        });
      });

      context('from unauthorized account', function () {
        const from = anyone;

        it('reverts via implicit sender address', async function () {
          await shouldFail.reverting(this.contract[`only${rolename}Mock`]({ from }));
        });

        it('reverts via explicit address', async function () {
          await shouldFail.reverting(this.contract[`require${rolename}Mock`](from, { from }));
        });
      });
    });

    describe('add', function () {
      it('adds role to a new account', async function () {
        await this.contract[`add${rolename}`](anyone, { from: authorized });
        (await this.contract[`is${rolename}`](anyone)).should.equal(true);
      });

      it(`emits a ${rolename}Added event`, async function () {
        const { logs } = await this.contract[`add${rolename}`](anyone, { from: authorized });
        expectEvent.inLogs(logs, `${rolename}Added`, { account: anyone });
      });

      it('reverts when adding role to an already assigned account', async function () {
        await shouldFail.reverting(this.contract[`add${rolename}`](authorized, { from: authorized }));
      });

      it('reverts when adding role to the null account', async function () {
        await shouldFail.reverting(this.contract[`add${rolename}`](ZERO_ADDRESS, { from: authorized }));
      });

      it('reverts when adding from unauthorized account', async function () {
        await shouldFail.reverting(this.contract[`add${rolename}`](otherAuthorized, { from: anyone }));
      });

      it('reverts when adding from authorized non-owner account', async function () {
        await shouldFail.reverting(this.contract[`add${rolename}`](anyone, { from: otherAuthorized }));
      });
    });

    describe('remove', function () {
      it('rejects unauthorized removal', async function () {
        await shouldFail.reverting(
          this.contract[`remove${rolename}`](authorized, { from: otherAuthorized }));
        await shouldFail.reverting(
          this.contract[`remove${rolename}`](authorized, { from: anyone }));
      });

      it('removes role from an already assigned account', async function () {
        await this.contract[`remove${rolename}`](authorized, { from: authorized });
        (await this.contract[`is${rolename}`](authorized)).should.equal(false);
        (await this.contract[`is${rolename}`](otherAuthorized)).should.equal(true);
      });

      it(`emits a ${rolename}Removed event`, async function () {
        const { logs } = await this.contract[`remove${rolename}`](
          authorized, { from: authorized });
        expectEvent.inLogs(logs, `${rolename}Removed`, { account: authorized });
      });

      it('reverts when removing from an unassigned account', async function () {
        await shouldFail.reverting(
          this.contract[`remove${rolename}`](anyone, { from: authorized }));
      });

      it('reverts when removing role from the null account', async function () {
        await shouldFail.reverting(
          this.contract[`remove${rolename}`](ZERO_ADDRESS, { from: authorized }));
      });

      it('reverts when removing from unauthorized account', async function () {
        await shouldFail.reverting(this.contract[`remove${rolename}`](otherAuthorized, { from: anyone }));
      });

      it('reverts when adding from authorized non-owner account', async function () {
        await shouldFail.reverting(this.contract[`remove${rolename}`](anyone, { from: otherAuthorized }));
      });
    });

    describe('renouncing roles', function () {
      it('renounces an assigned role', async function () {
        await this.contract[`renounce${rolename}`]({ from: authorized });
        (await this.contract[`is${rolename}`](authorized)).should.equal(false);
      });

      it(`emits a ${rolename}Removed event`, async function () {
        const { logs } = await this.contract[`renounce${rolename}`]({ from: authorized });
        expectEvent.inLogs(logs, `${rolename}Removed`, { account: authorized });
      });

      it('reverts when renouncing unassigned role', async function () {
        await shouldFail.reverting(this.contract[`renounce${rolename}`]({ from: anyone }));
      });
    });
  });
}

module.exports = {
  shouldBehaveLikePublicRole
};
