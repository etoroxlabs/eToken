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

/* global artifacts, web3, contract */
/* eslint-env mocha */

'use strict';

const TokenManager = artifacts.require('TokenManager');
const Accesslist = artifacts.require('Accesslist');
const EToken = artifacts.require('EToken');

const util = require('./utils.js');
const upgradeToken = require('../scripts/upgradeToken/upgradeToken.js');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('Upgrade Token', async function ([_, tokenManagerOwner, oldTokenOwner, newTokenOwner, storageOwner, ...accounts]) {
  it('Should upgrade properly and update TokenManager state and oldTokenState',
     async function () {
       const tokenName = 'test';
       const oldTokenDecimals = 4;
       const newTokenDecimals = 8;

       const tokenManager = await TokenManager.new({ from: tokenManagerOwner });

       const accesslist = await Accesslist.new();

       const oldToken = await EToken.new(
         tokenName, 'e', oldTokenDecimals,
         accesslist.address, true, util.ZERO_ADDRESS, 0xf00f, 0, true,
         { from: oldTokenOwner }
       );

       const storageAddress = await oldToken.getExternalStorage();

       const newToken = await EToken.new(
         tokenName, 'e', newTokenDecimals,
         accesslist.address, true,
         storageAddress, 0xf00f, oldToken.address, false,
         { from: newTokenOwner }
       );

       (await oldToken.decimals()).should.be.bignumber.equal(oldTokenDecimals);
       (await newToken.decimals()).should.be.bignumber.equal(newTokenDecimals);
       await util.assertReverts(tokenManager.getToken(tokenName));

       (await tokenManager.addToken(tokenName, oldToken.address, { from: tokenManagerOwner }));
       (await tokenManager.getToken(tokenName)).should.be.equal(oldToken.address);

       await upgradeToken(tokenManager, oldToken, newToken, tokenManagerOwner, oldTokenOwner);

       // Check if upgrade successful
       (await oldToken.decimals()).should.be.bignumber.equal(newTokenDecimals);
       (await newToken.decimals()).should.be.bignumber.equal(newTokenDecimals);
       (await tokenManager.getToken(tokenName)).should.be.equal(newToken.address);
     });
});
