/* global artifacts, web3, contract */
/* eslint-env mocha */

'use strict'

const TokenManager = artifacts.require('TokenManager')
const Accesslist = artifacts.require('Accesslist')
const EToroTokenMock = artifacts.require('EToroTokenMock')
const EToroToken = artifacts.require('EToroToken')

const util = require('./utils.js')
const upgradeToken = require('../scripts/upgradeToken/upgradeToken.js')

const BigNumber = web3.BigNumber

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should()

contract('Upgrade Token', async function ([_, tokenManagerOwner, oldTokenOwner, newTokenOwner, ...accounts]) {
  it('Should upgrade properly and update TokenManager state and oldTokenState', async function () {
    const tokenName = 'test'
    const oldTokenDecimals = 4
    const newTokenDecimals = 8

    const tokenManager = await TokenManager.new({ from: tokenManagerOwner })

    const accesslist = await Accesslist.new()

    const oldToken = await EToroTokenMock.new(
      tokenName, 'e', oldTokenDecimals,
      accesslist.address,
      { from: oldTokenOwner }
    )

    const storage = await oldToken._externalERC20Storage()

    const newToken = await EToroToken.new(
      tokenName, 'e', newTokenDecimals,
      accesslist.address, storage.address,
      { from: newTokenOwner }
    );

    (await oldToken.decimals()).should.be.bignumber.equal(oldTokenDecimals);
    (await newToken.decimals()).should.be.bignumber.equal(newTokenDecimals)
    await util.assertReverts(tokenManager.getToken(tokenName));

    (await tokenManager.addToken(tokenName, oldToken.address, { from: tokenManagerOwner }));
    (await tokenManager.getToken(tokenName)).should.be.equal(oldToken.address)

    await upgradeToken(tokenManager, oldToken, newToken, tokenManagerOwner, oldTokenOwner);

    // Check if upgrade successful
    (await oldToken.decimals()).should.be.bignumber.equal(newTokenDecimals);
    (await newToken.decimals()).should.be.bignumber.equal(newTokenDecimals);
    (await tokenManager.getToken(tokenName)).should.be.equal(newToken.address)
  })
})
