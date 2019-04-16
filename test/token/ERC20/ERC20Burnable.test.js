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
