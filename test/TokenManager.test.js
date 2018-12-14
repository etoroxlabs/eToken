/* global artifacts, contract, assert */
/* eslint-env mocha */

'use strict';

const util = require('./utils.js');
const { shouldBehaveLikeOwnable } =
      require('etokenize-openzeppelin-solidity/test/ownership/Ownable.behavior.js');

const TokenManager = artifacts.require('TokenManager');
const Accesslist = artifacts.require('Accesslist');
const EToroToken = artifacts.require('EToroToken');
const EToroTokenMock = artifacts.require('EToroTokenMock');

const tokName = 'eUSD';

contract('TokenManager', async ([owner, user, ...accounts]) => {
  let tokMgr;
  let accesslist;

  beforeEach(async function () {
    tokMgr = await TokenManager.new();
    accesslist = await Accesslist.new();
    this.ownable = tokMgr;
  });

  shouldBehaveLikeOwnable(owner, [user]);

  it('Should throw on retrieving non-existing entires', async () => {
    await util.assertReverts(tokMgr.getToken.call(tokName,
      { from: accounts[0] }));
  });

  it('should add tokens', async () => {
    const eToroToken = await EToroTokenMock.new(
      tokName, 'e', 4, accesslist.address,
      { from: owner }
    );

    await tokMgr.addToken(tokName, eToroToken.address, { from: owner });

    const address = await tokMgr.getToken.call(tokName, { from: owner });
    const tok = EToroToken.at(address);
    const contractTokName = await tok.name.call({ from: owner });

    assert(contractTokName === tokName,
      'Name of created contract did not match the expected');
  });

  it('should upgrade token', async () => {
    const eToroToken = await EToroTokenMock.new(
      tokName, 'e', 4, accesslist.address,
      { from: owner }
    );

    const eToroToken2 = await EToroTokenMock.new(
      tokName, 'e', 8, accesslist.address,
      { from: owner }
    );

    await tokMgr.addToken(tokName, eToroToken.address, { from: owner });
    const address = await tokMgr.getToken(tokName, { from: owner });

    assert(eToroToken.address === address,
      'Created contract did not match the expected');

    await tokMgr.upgradeToken(tokName, eToroToken2.address, { from: owner });
    const address2 = await tokMgr.getToken(tokName, { from: owner });

    assert(eToroToken2.address === address2,
      'Created contract did not match the expected');
  });

  it('fails on duplicated names', async () => {
    const tokName = 'eEUR';
    const eToroToken1 = await EToroTokenMock.new(
      tokName, 'e', 4, accesslist.address,
      { from: owner }
    );
    const eToroToken2 = await EToroTokenMock.new(
      tokName, 'se', 7, accesslist.address,
      { from: owner }
    );

    await tokMgr.addToken(tokName, eToroToken1.address, { from: owner });
    await util.assertReverts(tokMgr.addToken(tokName, eToroToken2.address, { from: owner }));
  });

  it('should properly remove tokens', async () => {
    let tokName = 'myTok';
    // Token shouldn't exist before creation
    await util.assertReverts(tokMgr.getToken.call(tokName, { from: owner }));

    // Create token and add token
    const eToroToken = await EToroTokenMock.new(
      tokName, 'e', 4, accesslist.address,
      { from: owner }
    );
    await tokMgr.addToken(tokName, eToroToken.address, { from: owner });

    // Retrieve token. This should be successful
    await tokMgr.getToken.call(tokName, { from: owner });
    // Delete token
    await tokMgr.deleteToken(tokName, { from: owner });
    // Token should now no longer exist
    await util.assertReverts(tokMgr.getToken.call(tokName, { from: owner }));
  });
  it('should reject null IEtoroToken', async () => {
    const nulltoken = util.ZERO_ADDRESS;
    await util.assertReverts(tokMgr.addToken('nulltoken', nulltoken, { from: owner }));
  });
});

contract('Token manager list retrieve', async (accounts) => {
  let tokMgr;
  let accesslist;
  let owner = accounts[0];

  before(async () => {
    tokMgr = await TokenManager.new();
    accesslist = await Accesslist.new();
  });

  it('returns an empty list initially', async () => {
    const expected = [];

    const r = await tokMgr.getTokens.call({ from: owner });

    assert.deepEqual(r, expected,
      'Token list returned does not match expected');
  });

  it('returns a list of created tokens', async () => {
    const expected = ['tok1', 'tok2'];

    const eToroToken1 = await EToroTokenMock.new(
      'tok1', 'e', 4, accesslist.address,
      { from: owner }
    );

    const eToroToken2 = await EToroTokenMock.new(
      'tok2', 'e', 4, accesslist.address,
      { from: owner }
    );

    await tokMgr.addToken('tok1', eToroToken1.address, { from: owner });
    await tokMgr.addToken('tok2', eToroToken2.address, { from: owner });

    const r = (await tokMgr.getTokens.call({ from: owner }))
      .map(util.bytes32ToString);
    // Sort arrays since implementation does not require stable order of tokens
    assert.deepEqual(r.sort(), expected.sort(),
      'Token list returned does not match expected');

    // Cleanup
    expected.map(async x => { await tokMgr.deleteToken(x, { from: owner }); });
  });

  it('Elements are set to 0 when deleted', async () => {
    let expected = [0, 0];
    let actual = (await tokMgr.getTokens.call({ from: owner }))
      .map((x) => parseInt(x));
    assert.deepEqual(actual, expected,
      'Token list returned does not match expected');
  });
});

contract('Token manager permissions', async (accounts) => {
  let tokMgr;
  let accesslist;
  let owner = accounts[0];
  let user = accounts[1];

  beforeEach(async () => {
    tokMgr = await TokenManager.new();
    accesslist = await Accesslist.new();
  });

  it('Rejects unauthorized newToken', async () => {
    const eToroToken = await EToroTokenMock.new(
      tokName, 'e', 4, Accesslist.address,
      { from: owner }
    );

    await util.assertReverts(tokMgr.addToken(
      tokName, eToroToken.address,
      { from: user }
    ));
  });

  it('Rejects unauthorized deleteToken', async () => {
    const eToroToken = await EToroTokenMock.new(
      tokName, 'e', 4, accesslist.address,
      { from: owner }
    );
    tokMgr.addToken(
      tokName, eToroToken.address,
      { from: owner }
    );

    await util.assertReverts(tokMgr.deleteToken(tokName, { from: user }));

    const tokenAddress = await tokMgr.getToken.call(tokName, { from: owner });
    assert(tokenAddress === eToroToken.address);
  });

  it('Rejects unauthorized upgradeToken', async () => {
    const eToroToken = await EToroTokenMock.new(
      tokName, 'e', 4, accesslist.address,
      { from: owner }
    );

    const eToroToken2 = await EToroTokenMock.new(
      tokName, 'e', 8, accesslist.address,
      { from: owner }
    );

    await tokMgr.addToken(tokName, eToroToken.address, { from: owner });
    const address = await tokMgr.getToken(tokName);

    assert(eToroToken.address === address,
      'Created contract did not match the expected');

    await util.assertReverts(tokMgr.upgradeToken(tokName, eToroToken2.address, { from: user }));
    const address2 = await tokMgr.getToken(tokName);

    assert(eToroToken.address === address2,
      'Created contract did not match the expected');
  });
});
