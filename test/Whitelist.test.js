'use strict';

const util = require("./utils.js");
const { inLogs }
      = require("openzeppelin-solidity/test/helpers/expectEvent.js");

const Whitelist = artifacts.require("Whitelist");

contract("Whitelist", async function ([owner, user, user1, user2, user3,
                                       user4, user5, user6, ...accounts]) {

    beforeEach(async function() {
        this.wl = await Whitelist.new();
        const events = [{eventName: "OwnershipTransferred",
                         paramMap: {previousOwner: '0x0000000000000000000000000000000000000000',
                                    newOwner: owner}},
                        {eventName: "WhitelistAdminAdded",
                         paramMap: {account: owner}}];
        await util.emittedEventsContract(this.wl, events);
    });

    it("is initially not in whitelist from unprivileged", async function() {
        assert( ! (await this.wl.isWhitelisted.call(user, {from: user1})));
    });

    it("is initially not in whitelist from privileged", async function() {
        assert( ! (await this.wl.isWhitelisted.call(user, {from: owner})));
    });

    it("owner (creator) is whitelisted from privileged", async function() {
        assert(await this.wl.isWhitelisted.call(owner, {from: owner}));
    });

    it("owner (creator) is whitelisted from unprivileged", async function() {
        assert(await this.wl.isWhitelisted.call(owner, {from: user1}));
    });

    async function addWhitelisted(t, user, from) {
        const { logs } = await t.wl.addWhitelisted(user, {from: owner});
        inLogs(logs, "WhitelistAdded");
    }

    it("allows privileged to add to whitelist", async function() {
        assert( ! (await this.wl.isWhitelisted.call(user, {from: owner})));
        addWhitelisted(this, user, owner);
        assert(await this.wl.isWhitelisted.call(user, {from: owner}));
    });

    it("rejects privileged attempt to add same user to whitelist multiple times", async function() {
        assert( ! (await this.wl.isWhitelisted.call(user2, {from: owner})));
        addWhitelisted(this, user2, owner);
        await util.assertReverts(this.wl.addWhitelisted(user2, {from: owner}));
        assert(await this.wl.isWhitelisted.call(user2, {from: owner}));
    });

    it("allows privileged to remove from whitelist", async function() {
        assert( ! (await this.wl.isWhitelisted.call(user1, {from: owner})));
        await this.wl.addWhitelisted(user1, {from: owner});
        assert((await this.wl.isWhitelisted.call(user1, {from: owner})));
        await this.wl.removeWhitelisted(user1, {from: owner});
        assert( ! (await this.wl.isWhitelisted.call(user1, {from: owner})));
    });

    it("rejects unprivileged from adding to whitelist", async function() {
        assert( ! (await this.wl.isWhitelisted.call(user3, {from: user2})));
        await util.assertReverts(this.wl.addWhitelisted(user3, {from: user2}));
        assert( ! (await this.wl.isWhitelisted.call(user3, {from: user2})));
    });

    it("rejects unprivileged from removing from whitelist", async function() {
        await this.wl.addWhitelisted(user3, {from: owner});
        util.assertReverts(this.wl.removeWhitelisted(user3, {from: user2}));
        assert(await this.wl.isWhitelisted.call(user3, {from: user2}));
    });

    it("allows privileged privilege propagation", async function() {
        assert( ! (await this.wl.isWhitelistAdmin.call(user4, {from: owner})));
        await util.assertReverts(this.wl.addWhitelisted(user4, {from: user3}));
        await this.wl.addWhitelistAdmin(user3, {from: owner});
        assert(await this.wl.isWhitelistAdmin.call(user3, {from: owner}));
        await this.wl.addWhitelisted(user4, {from: user3});
        assert(await this.wl.isWhitelisted(user4, {from: user3}));
    });

    it("rejects unprivileged privilege propagation", async function() {
        assert( ! (await this.wl.isWhitelistAdmin.call(user6, {from: user5})));
        await util.assertReverts(this.wl.addWhitelisted(user6, {from: user5}));
        await util.assertReverts(this.wl.addWhitelistAdmin(user6, {from: user5}));
        assert( ! (await this.wl.isWhitelistAdmin.call(user6, {from: user5})));
        await util.assertReverts(this.wl.addWhitelisted(user6, {from: user5}));
    });
});
