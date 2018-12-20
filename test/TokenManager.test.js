/* global artifacts, contract, assert */
/* eslint-env mocha */

'use strict';

const util = require('./utils.js');
const { shouldBehaveLikeOwnable } =
      require('openzeppelin-solidity/test/ownership/Ownable.behavior.js');

const TokenManager = artifacts.require('TokenManager');
const Accesslist = artifacts.require('Accesslist');
const EToroToken = artifacts.require('EToroToken');
const EToroTokenMock = artifacts.require('EToroTokenMock');

const tokName = 'eUSD';

contract('TokenManager', async ([owner, user, ...accounts]) => {
  beforeEach(async () => {
    this.tokMgr = await TokenManager.new();
    this.accesslist = await Accesslist.new();

    this.eToroToken = await EToroTokenMock.new(
      tokName, 'e', 4, this.accesslist.address, true,
      { from: owner }
    );

    this.eToroToken2 = await EToroTokenMock.new(
      tokName, 'se', 8, this.accesslist.address, true,
      { from: owner }
    );
  });

  describe('OpenZeppelin ownable behavior', () => {
    beforeEach(async function () {
      this.ownable = await TokenManager.new();
    });

    shouldBehaveLikeOwnable(owner, [user]);
  });

  it('Should throw on retrieving non-existing entires', async () => {
    await util.assertReverts(
      this.tokMgr.getToken(tokName, { from: accounts[0] })
    );
  });

  describe('When added token', () => {
    beforeEach(async () => {
      await this.tokMgr.addToken(
        tokName, this.eToroToken.address,
        { from: owner }
      );
    });

    it('should add tokens', async () => {
      const address = await this.tokMgr.getToken(tokName, { from: owner });
      const tok = EToroToken.at(address);
      const contractTokName = await tok.name({ from: owner });

      assert(
        contractTokName === tokName,
        'Name of created contract did not match the expected'
      );
    });

    it('should upgrade token', async () => {
      const address = await this.tokMgr.getToken(tokName, { from: owner });

      assert(
        this.eToroToken.address === address,
        'Created contract did not match the expected'
      );

      await this.tokMgr.upgradeToken(
        tokName, this.eToroToken2.address,
        { from: owner }
      );

      const address2 = await this.tokMgr.getToken(tokName, { from: owner });

      assert(
        this.eToroToken2.address === address2,
        'Created contract did not match the expected'
      );
    });

    it('fails on duplicated names', async () => {
      await util.assertReverts(
        this.tokMgr.addToken(tokName, this.eToroToken2.address, { from: owner })
      );
    });
  });

  it('should properly remove tokens', async () => {
    // Token shouldn't exist before creation
    await util.assertReverts(this.tokMgr.getToken(tokName, { from: owner }));

    // Create token and add token
    await this.tokMgr.addToken(tokName, this.eToroToken.address, { from: owner });

    // Retrieve token. This should be successful
    await this.tokMgr.getToken(tokName, { from: owner });
    // Delete token
    await this.tokMgr.deleteToken(tokName, { from: owner });
    // Token should now no longer exist
    await util.assertReverts(
      this.tokMgr.getToken(tokName, { from: owner })
    );
  });

  it('should reject null IEtoroToken', async () => {
    const nulltoken = util.ZERO_ADDRESS;
    await util.assertReverts(
      this.tokMgr.addToken('nulltoken', nulltoken, { from: owner })
    );
  });

  describe('Get Tokens', () => {
    it('returns an empty list initially', async () => {
      const expected = [];

      const r = await this.tokMgr.getTokens({ from: owner });

      assert.deepEqual(
        r, expected,
        'Token list returned does not match expected'
      );
    });

    describe('when tokens are added', () => {
      beforeEach(async () => {
        this.expected = ['tok1', 'tok2'];

        this.eToroToken = await EToroTokenMock.new(
          this.expected[0], 'e', 4, this.accesslist.address, true,
          { from: owner }
        );

        this.eToroToken2 = await EToroTokenMock.new(
          this.expected[1], 'e', 4, this.accesslist.address, true,
          { from: owner }
        );

        await this.tokMgr.addToken(
          this.expected[0], this.eToroToken.address,
          { from: owner }
        );

        await this.tokMgr.addToken(
          this.expected[1], this.eToroToken2.address,
          { from: owner }
        );
      });

      it('returns a list of created tokens', async () => {
        const r = (await this.tokMgr.getTokens({ from: owner }))
          .map(util.bytes32ToString);

        // Sort arrays since implementation
        // does not require stable order of tokens
        assert.deepEqual(
          r.sort(), this.expected.sort(),
          'Token list returned does not match expected'
        );
      });

      it('Elements are set to 0 when deleted', async () => {
        // Delete existing tokens
        await Promise.all(
          this.expected.map(x => this.tokMgr.deleteToken(x, { from: owner }))
        );

        const expected = [0, 0];
        const actual = (await this.tokMgr.getTokens({ from: owner }))
          .map((x) => parseInt(x));

        assert.deepEqual(
          actual, expected,
          'Token list returned does not match expected'
        );
      });
    });
  });

  describe('Permissions', () => {
    it('Rejects unauthorized newToken', async () => {
      await util.assertReverts(this.tokMgr.addToken(
        tokName, this.eToroToken.address,
        { from: user }
      ));
    });

    it('Rejects unauthorized deleteToken', async () => {
      this.tokMgr.addToken(
        tokName, this.eToroToken.address,
        { from: owner }
      );

      await util.assertReverts(
        this.tokMgr.deleteToken(tokName, { from: user })
      );

      const tokenAddress = await this.tokMgr.getToken(tokName, { from: owner });
      assert(tokenAddress === this.eToroToken.address);
    });

    it('Rejects unauthorized upgradeToken', async () => {
      await this.tokMgr.addToken(
        tokName, this.eToroToken.address,
        { from: owner }
      );

      const address = await this.tokMgr.getToken(tokName);

      assert(
        this.eToroToken.address === address,
        'Created contract did not match the expected'
      );

      await util.assertReverts(
        this.tokMgr.upgradeToken(
          tokName, this.eToroToken2.address,
          { from: user }
        )
      );

      const address2 = await this.tokMgr.getToken(tokName);

      assert(
        this.eToroToken.address === address2,
        'Created contract did not match the expected'
      );
    });
  });
});
