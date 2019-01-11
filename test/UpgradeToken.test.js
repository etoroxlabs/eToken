/* global artifacts, web3, contract */
/* eslint-env mocha */

'use strict';

const TokenManager = artifacts.require('TokenManager');
const Accesslist = artifacts.require('Accesslist');
const TokenX = artifacts.require('TokenX');
const ExternalERC20Storage = artifacts.require('ExternalERC20Storage');

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

       const storage = await ExternalERC20Storage.new({ from: storageOwner });

       const oldToken = await TokenX.new(
         tokenName, 'e', oldTokenDecimals,
         accesslist.address, true, storage.address, 0xf00f, 0, true,
         { from: oldTokenOwner }
       );

       const newToken = await TokenX.new(
         tokenName, 'e', newTokenDecimals,
         accesslist.address, true,
         storage.address, 0xf00f, oldToken.address, false,
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
