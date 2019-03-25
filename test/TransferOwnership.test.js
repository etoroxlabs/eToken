/* global artifacts, web3, contract */
/* eslint-env mocha */

'use strict';

const assert = require('assert');

const Accesslist = artifacts.require('Accesslist');
const ETokenMock = artifacts.require('ETokenMock');

const utils = require('./utils.js');
const transferOwnershipHelper = require('../scripts/transferOwnership/transferOwnershipHelper.js');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('Disable Token', async function ([_, owner, otherAccount]) {
  it('Should properly transfer ownership',
     async function () {
       const NO_OF_TOKENS = 2;

       const tokenName = 'test';
       const tokenSymbol = 'test';
       const tokenDecimals = 4;

       const accesslist = await Accesslist.new();

       const createToken = () => ETokenMock.new(
         tokenName, tokenSymbol, tokenDecimals,
         accesslist.address, false, utils.ZERO_ADDRESS, owner, 0, true,
         owner, 10000,
         { from: owner }
       );

       const ownableTokens = await Promise.all(Array(NO_OF_TOKENS).fill(undefined).map(_ => createToken()));
       const getOwners = () => Promise.all(ownableTokens.map(o => o.owner()));

       const oldOwners = await getOwners();
       assert.strict.deepEqual(oldOwners, Array(NO_OF_TOKENS).fill(owner));

       await transferOwnershipHelper(owner, otherAccount, ownableTokens);

       const newOwners = await getOwners();
       assert.strict.deepEqual(newOwners, Array(NO_OF_TOKENS).fill(otherAccount));
     });
});
