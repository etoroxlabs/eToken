/* global artifacts, web3, contract */
/* eslint-env mocha */

'use strict';

const assert = require('assert');

const Accesslist = artifacts.require('Accesslist');
const ETokenMock = artifacts.require('ETokenMock');
const Storage = artifacts.require('Storage');
const Ownable = artifacts.require('Ownable');

const utils = require('./utils.js');
const transferTokenOwnershipHelper = require('../scripts/transferTokenOwnership/transferTokenOwnershipHelper.js');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('Transfer token', async function ([_, owner, otherAccount]) {
  it('Should properly transfer token ownership',
     async function () {
       const NO_OF_TOKENS = 5;

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
       const getStorageOwners = () =>
         Promise
           .all(ownableTokens.map(o => o.getExternalStorage().then(s => Storage.at(s))))
           .then((storages) => Promise.all(storages.map(s => s.owner())));
       const getIfBurner = () => Promise.all(ownableTokens.map(o => o.isBurner(owner)));
       const getIfMinter = () => Promise.all(ownableTokens.map(o => o.isMinter(owner)));
       const getIfPauser = () => Promise.all(ownableTokens.map(o => o.isPauser(owner)));

       const oldOwners = await getOwners();
       const oldStorageOwners = await getStorageOwners();
       assert.strict.deepEqual(oldOwners, Array(NO_OF_TOKENS).fill(owner));
       assert.strict.deepEqual(oldStorageOwners, Array(NO_OF_TOKENS).fill(owner));

       await transferTokenOwnershipHelper(Ownable.at, owner, otherAccount, ownableTokens);

       const newOwners = await getOwners();
       const newStorageOwners = await getStorageOwners();
       assert.strict.deepEqual(newOwners, Array(NO_OF_TOKENS).fill(otherAccount));
       assert.strict.deepEqual(newStorageOwners, Array(NO_OF_TOKENS).fill(otherAccount));

       const ifBurner = await getIfBurner();
       const ifMinter = await getIfMinter();
       const ifPauser = await getIfPauser();
       assert.strict.deepEqual(ifBurner, Array(NO_OF_TOKENS).fill(false));
       assert.strict.deepEqual(ifMinter, Array(NO_OF_TOKENS).fill(false));
       assert.strict.deepEqual(ifPauser, Array(NO_OF_TOKENS).fill(false));
     });
});
