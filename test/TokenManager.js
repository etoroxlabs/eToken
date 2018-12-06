'use strict';

const util = require("./utils.js");
const { shouldBehaveLikeOwnable }
      = require("openzeppelin-solidity/test/ownership/Ownable.behavior.js")

const TokenManager = artifacts.require("TokenManager");
const Whitelist = artifacts.require("Whitelist");
const EToroToken = artifacts.require("EToroToken");

const tokName = "eUSD";

contract("TokenManager", async (accounts) => {

    let tokMgr;
    let whitelist;
    let a0 = accounts[0];
    let user = accounts[1];

    beforeEach(async function () {
        tokMgr = await TokenManager.new();
        whitelist = await Whitelist.new();
        this.ownable = tokMgr;
    });

    shouldBehaveLikeOwnable(a0, [user]);

    it("Should throw on retrieving non-existing entires", async () => {
        await util.assertReverts(tokMgr.getToken.call(tokName,
                                                      {from: accounts[0]}));
    });

    it("should create and retrieve tokens", async () => {
        await tokMgr.newToken(tokName, "e", 4, whitelist.address, {from: a0});
        let res = await tokMgr.getToken.call(tokName, {from: a0});
        let tok = EToroToken.at(res);
        let contractTokName = await tok.name.call({from: a0})
        assert(contractTokName === tokName,
               "Name of created contract did not match the expected");
    });

    it("fails on duplicated names", async () => {
        let tokName = "eEUR";
        await tokMgr.newToken(tokName, "e", 4, whitelist.address, {from: a0});
        await util.assertReverts(
            tokMgr.newToken(tokName, "e", 4, whitelist.address, {from: a0}));
    });

    it("should properly remove tokens", async () => {
        let tokName = "myTok";
        // Token shouldn't exist before creation
        await util.assertReverts(tokMgr.getToken.call(tokName, {from: a0}));
        // Create token
        await tokMgr.newToken(tokName, "e", 4, whitelist.address, {from: a0});
        // Retrieve token. This should be successful
        await tokMgr.getToken.call(tokName, {from: a0});
        // Delete token
        await tokMgr.deleteToken(tokName, {from: a0});
        // Token should now no longer exist
        await util.assertReverts(tokMgr.getToken.call(tokName, {from: a0}));
    });

})


contract("Token manager list retrieve", async (accounts) => {
    let tokMgr;
    let whitelist;
    let a0 = accounts[0];

    before(async () => {
        tokMgr = await TokenManager.new();
        whitelist = await Whitelist.new();
    });

    it("returns an empty list initially", async () => {
        let expected = [];

        let r = await tokMgr.getTokens.call({from: a0});

        assert.deepEqual(r, expected,
               "Token list returned does not match expected");

    });


    it("returns a list of created tokens", async () => {
        let expected = ["tok1", "tok2"];

        await tokMgr.newToken("tok1", "e", 4, whitelist.address, {from: a0});
        await tokMgr.newToken("tok2", "e", 4, whitelist.address, {from: a0});

        let r = (await tokMgr.getTokens.call({from: a0}))
            .map(util.bytes32ToString);
        // Sort arrays since implementation does not require stable order of tokens
        assert.deepEqual(r.sort(), expected.sort(),
               "Token list returned does not match expected");

        // Cleanup
        expected.map(async x => { await tokMgr.deleteToken(x, {from: a0}) });
    });


    it("Elements are set to 0 when deleted", async () => {
        let expected = [0, 0];
        let actual = (await tokMgr.getTokens.call({from: a0}))
            .map((x) => parseInt(x));
        assert.deepEqual(actual, expected,
                         "Token list returned does not match expected");

    });

});

contract("Token manager permissions", async (accounts) => {
    let tokMgr;
    let whitelist;
    let owner = accounts[0];
    let user = accounts[1];

    before(async () => {
        tokMgr = await TokenManager.new();
        whitelist = await Whitelist.new();
    });

    it("Rejects unauthorized newToken", async () => {
        await util.assertReverts(tokMgr.newToken(tokName, "e", 4,
                                                 whitelist.address,
                                                 {from: user}));
    });

    it("Rejects unauthorized deleteToken", async () => {
        await tokMgr.newToken(tokName, "e", 4, whitelist.address,
                              {from: owner});
        await util.assertReverts(tokMgr.deleteToken(tokName, {from: user}));
    });
});
