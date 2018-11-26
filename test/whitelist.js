'use strict';

const util = require("./utils.js");

const Whitelist = artifacts.require("Whitelist");

contract("Whitelist", async (accounts) => {

    let wl;
    let owner = accounts[0];
    let user = accounts[1];
    let user1 = accounts[2];
    let user2 = accounts[3];
    let user3 = accounts[4];
    let user4 = accounts[5];
    let user5 = accounts[6];
    let user6 = accounts[7];


    before(async () => {
        wl = await Whitelist.deployed();
    });

    it("is initially not in whitelist from unprivileged", async () => {
        assert( ! (await wl.isWhitelisted.call(user, {from: user1})));
    });

    it("is initially not in whitelist from privileged", async () => {
        assert( ! (await wl.isWhitelisted.call(user, {from: owner})));
    });

    it("owner (creator) is whitelisted from privileged", async () => {
        assert(await wl.isWhitelisted.call(owner, {from: owner}));
    });

    it("owner (creator) is whitelisted from unprivileged", async () => {
        assert(await wl.isWhitelisted.call(owner, {from: user1}));
    });

    it("allows privileged to add to whitelist", async () => {
        assert( ! (await wl.isWhitelisted.call(user, {from: owner})));
        await wl.addWhitelisted(user, {from: owner});
        assert(await wl.isWhitelisted.call(user, {from: owner}));
    });

    it("allows privileged to remove from whitelist", async () => {
        assert( ! (await wl.isWhitelisted.call(user1, {from: owner})));
        await wl.addWhitelisted(user1, {from: owner});
        assert((await wl.isWhitelisted.call(user1, {from: owner})));
        await wl.removeWhitelisted(user1, {from: owner});
        assert( ! (await wl.isWhitelisted.call(user1, {from: owner})));
    });

    it("rejects unprivileged from adding to whitelist", async () => {
        assert( ! (await wl.isWhitelisted.call(user3, {from: user2})));
        util.assertReverts(wl.addWhitelisted(user3, {from: user2}));
        assert( ! (await wl.isWhitelisted.call(user3, {from: user2})));
    });

    it("rejects unprivileged from removing from whitelist", async () => {
        await wl.addWhitelisted(user3, {from: owner});
        util.assertReverts(wl.removeWhitelisted(user3, {from: user2}));
        assert(await wl.isWhitelisted.call(user3, {from: user2}));
    });

    it("allows privileged privilege propagation", async () => {
        assert( ! (await wl.isWhitelistAdmin.call(user4, {from: owner})));
        util.assertReverts(wl.addWhitelisted(user4, {from: user3}));
        await wl.addWhitelistAdmin(user4, {from: owner});
        assert(await wl.isWhitelistAdmin.call(user4, {from: owner}));
        await wl.addWhitelisted(user4, {from: user3});
    });

    it("rejects unprivileged privilege propagation", async () => {
         assert( ! (await wl.isWhitelistAdmin.call(user6, {from: user3})));
         util.assertReverts(wl.addWhitelisted(user6, {from: user3}));
    //     util.assertReverts(wl.addWhitelistAdmin(user5, {from: user3}));
    //     assert( ! (await wl.isWhitelistAdmin.call(user5, {from: user3})));
    //     util.assertReverts(wl.addWhitelisted(user5, {from: user3}));
    });
});
