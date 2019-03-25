/* global artifacts, web3, contract */
/* eslint-env mocha */

'use strict';

const Accesslist = artifacts.require('Accesslist');
const ETokenMock = artifacts.require('ETokenMock');
const DisableToken = artifacts.require('DisableToken');

const utils = require('./utils.js');
const disableTokenHelper = require('../scripts/disableToken/disableTokenHelper.js');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('Disable Token', async function ([_, owner, otherAccount]) {
  it('Should properly disable token',
     async function () {
       const tokenName = 'test';
       const tokenSymbol = 'test';
       const tokenDecimals = 4;

       const accesslist = await Accesslist.new();

       const token = await ETokenMock.new(
         tokenName, tokenSymbol, tokenDecimals,
         accesslist.address, false, utils.ZERO_ADDRESS, owner, 0, true,
         owner, 10000,
         { from: owner }
       );

       await token.approve(otherAccount, 100, { from: owner });

       (await token.name()).should.be.equal(tokenName);
       (await token.symbol()).should.be.equal(tokenSymbol);
       (await token.decimals()).should.be.bignumber.equal(tokenDecimals);
       (await token.totalSupply()).should.be.bignumber.equal(10000);
       (await token.balanceOf(owner)).should.be.bignumber.equal(10000);
       (await token.allowance(owner, otherAccount)).should.be.bignumber.equal(100);

       await disableTokenHelper(DisableToken, token, owner);

       (await token.name()).should.be.equal('DO NOT USE - Disabled');
       (await token.symbol()).should.be.equal('DEAD');
       (await token.decimals()).should.be.bignumber.equal(0);
       (await token.totalSupply()).should.be.bignumber.equal(0);
       (await token.balanceOf(owner)).should.be.bignumber.equal(0);
       (await token.allowance(owner, otherAccount)).should.be.bignumber.equal(0);

       const crippledText = 'Token is disabled';
       await utils.assertRevertsReason(token.transfer(owner, 100), crippledText);
       await utils.assertRevertsReason(token.approve(owner, 100), crippledText);
       await utils.assertRevertsReason(token.transferFrom(owner, owner, 100), crippledText);
       await utils.assertRevertsReason(token.increaseAllowance(owner, 100), crippledText);
       await utils.assertRevertsReason(token.decreaseAllowance(owner, 100), crippledText);
       await utils.assertRevertsReason(token.burn(100), crippledText);
       await utils.assertRevertsReason(token.burnFrom(owner, 100), crippledText);
       await utils.assertRevertsReason(token.mint(owner, 100), crippledText);
       await utils.assertRevertsReason(token.changeMintingRecipient(owner), crippledText);
       await utils.assertRevertsReason(token.pause(), crippledText);
       await utils.assertRevertsReason(token.unpause(), crippledText);
       await utils.assertRevertsReason(token.paused(), crippledText);

       const disabledToken = DisableToken.at(await token.getUpgradedToken());
       await utils.assertRevertsReason(disabledToken.upgrade(utils.ZERO_ADDRESS), crippledText);
     });
});
