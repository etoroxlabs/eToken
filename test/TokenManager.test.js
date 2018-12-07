'use strict';

const util = require("./utils.js");
const { shouldBehaveLikeOwnable }
      = require("openzeppelin-solidity/test/ownership/Ownable.behavior.js")

const ExternalERC20Storage = artifacts.require("ExternalERC20Storage");
const TokenManager = artifacts.require("TokenManager");
const Whitelist = artifacts.require("Whitelist");
const EToroToken = artifacts.require("EToroToken");

const tokName = "eUSD";

contract("TokenManager", async ([owner, user, ...accounts]) => {

    let tokMgr;
    let whitelist;

    beforeEach(async function () {
        tokMgr = await TokenManager.new();
        whitelist = await Whitelist.new();
        this.ownable = tokMgr;
    });

    shouldBehaveLikeOwnable(owner, [user]);

    it("Should throw on retrieving non-existing entires", async () => {
        await util.assertReverts(tokMgr.getToken.call(tokName,
                                                      {from: accounts[0]}));
    });

    it("should create and retrieve tokens", async () => {
        const externalERC20Storage = await ExternalERC20Storage.new();
        await tokMgr.newToken(tokName, "e", 4,
                              whitelist.address,
                              externalERC20Storage.address,
                              {from: owner});

        let address = await tokMgr.getToken.call(tokName, {from: owner});
        let tok = EToroToken.at(address);
        let contractTokName = await tok.name.call({from: owner})
        assert(contractTokName === tokName,
               "Name of created contract did not match the expected");
    });

    it("fails on duplicated names", async () => {
        let tokName = "eEUR";
        const externalERC20Storage = await ExternalERC20Storage.new();
        await tokMgr.newToken(tokName, "e", 4, whitelist.address,
                              externalERC20Storage.address, {from: owner});
        await util.assertReverts(
            tokMgr.newToken(tokName, "e", 4,
                            whitelist.address,
                            externalERC20Storage.address,
                            {from: owner}));
    });

    it("should properly remove tokens", async () => {
        let tokName = "myTok";
        // Token shouldn't exist before creation
        await util.assertReverts(tokMgr.getToken.call(tokName, {from: owner}));
        // Create token
        const externalERC20Storage = await ExternalERC20Storage.new();
        await tokMgr.newToken(tokName, "e", 4,
                              whitelist.address,
                              externalERC20Storage.address,
                              {from: owner});
        // Retrieve token. This should be successful
        await tokMgr.getToken.call(tokName, {from: owner});
        // Delete token
        await tokMgr.deleteToken(tokName, {from: owner});
        // Token should now no longer exist
        await util.assertReverts(tokMgr.getToken.call(tokName, {from: owner}));
    });

})


contract("Token manager list retrieve", async (accounts) => {
    let tokMgr;
    let whitelist;
    let owner = accounts[0];

    before(async () => {
        tokMgr = await TokenManager.new();
        whitelist = await Whitelist.new();
    });

    it("returns an empty list initially", async () => {
        let expected = [];

        let r = await tokMgr.getTokens.call({from: owner});

        assert.deepEqual(r, expected,
               "Token list returned does not match expected");

    });


    it("returns a list of created tokens", async () => {
        let expected = ["tok1", "tok2"];

        const externalERC20Storage = await ExternalERC20Storage.new();
        await tokMgr.newToken("tok1", "e", 4,
                              whitelist.address,
                              externalERC20Storage.address,
                              {from: owner});

        const externalERC20Storage2 = await ExternalERC20Storage.new();
        await tokMgr.newToken("tok2", "e", 4,
                              whitelist.address,
                              externalERC20Storage2.address,
                              {from: owner});

        let r = (await tokMgr.getTokens.call({from: owner}))
            .map(util.bytes32ToString);
        // Sort arrays since implementation does not require stable order of tokens
        assert.deepEqual(r.sort(), expected.sort(),
               "Token list returned does not match expected");

        // Cleanup
        expected.map(async x => { await tokMgr.deleteToken(x, {from: owner}) });
    });


    it("Elements are set to 0 when deleted", async () => {
        let expected = [0, 0];
        let actual = (await tokMgr.getTokens.call({from: owner}))
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
        const externalERC20Storage = await ExternalERC20Storage.new();
        await util.assertReverts(tokMgr.newToken(tokName, "e", 4,
                                                 whitelist.address,
                                                 externalERC20Storage.address,
                                                 {from: user}));
    });

    it("Rejects unauthorized deleteToken", async () => {
        const externalERC20Storage = await ExternalERC20Storage.new();
        await tokMgr.newToken(tokName, "e", 4,
                              whitelist.address,
                              externalERC20Storage.address,
                              {from: owner});
        await util.assertReverts(tokMgr.deleteToken(tokName, {from: user}));
    });
});
