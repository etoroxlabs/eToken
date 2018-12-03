'use strict';

const util = require("./utils.js");

const TokenManager = artifacts.require("TokenManager");
const Whitelist = artifacts.require("Whitelist");
const EToroToken = artifacts.require("EToroToken");

const ERROR = new Error('should not have reached this');
const isSolidityError = (e) => e.message === 'VM Exception while processing transaction: revert';

contract('EToro Token', accounts => {
    const owner = accounts[0];
    const admin = accounts[1];
    const whitelisted = accounts[2];
    const user = accounts[3];
    const user1 = accounts[3];

    let token;
    let WHITELISTED, ADMIN;

    before(async () => {
        let tokMgr = await TokenManager.deployed();
        let role = await Whitelist.deployed();

        // Create a token token
        await tokMgr.newToken("eUSD", "e", 1000, role.address, {from: owner});
        token = EToroToken.at(await tokMgr.getToken.call("eUSD", {from: owner}));
        //await token.addMinterQ


        //WHITELISTED = await token.ROLE_WHITELISTED.call();
        //ADMIN = await token.ROLE_ADMIN.call();
    });

    describe('Minting and Burning', function() {
        it('should mint new tokens', async () => {
            const mintVal = 1000;
            const initialBalance = await token.balanceOf.call(owner);
            const initialSupply = await token.totalSupply.call();
            let res = await token.isMinter.call(owner, {from: owner});
            await token.mint(owner, mintVal, {from: owner});
            const balance = await token.balanceOf.call(owner);
            const supply = await token.totalSupply.call();
            assert(balance.equals(initialBalance.plus(mintVal)));
            assert(supply.equals(initialSupply.plus(mintVal)));
        });

        it('should burn tokens', async () => {
            const burnVal = 500;
            const initialBalance = await token.balanceOf.call(owner, {from: owner});
            const initialSupply = await token.totalSupply.call({from: owner});
            await token.burn(burnVal, { from: owner });
            const balance = await token.balanceOf.call(owner, {from: owner});
            const supply = await token.totalSupply.call({from: owner});
            assert(balance.equals(initialBalance.minus(burnVal)));
            assert(supply.equals(initialSupply.minus(burnVal)));
        });

        // it('should not allow non minter to mint tokens', async () => {
        //     const initialBalance = await token.balanceOf.call(admin);
        //     util.assertThrows(await token.mint(admin, 1, {from: admin}));
        //     const balance = await token.balanceOf.call(admin);
        //     assert(balance.equals(initialBalance));
        // });
    });
});

contract('EToro Token default permissions ', async (accounts) => {

    const owner = accounts[0];
    const admin = accounts[1];
    const whitelisted = accounts[2];
    const user = accounts[3];
    const user2 = accounts[4];

    let token;

    before(async () => {
        let tokMgr = await TokenManager.deployed();
        let role = await Whitelist.deployed();

        // Create a token token
        await tokMgr.newToken("eUSD", "e", 4, role.address, {from: owner});
        token = EToroToken.at(await tokMgr.getToken.call("eUSD", {from: owner}));
        //await token.addMinterQ


        //WHITELISTED = await token.ROLE_WHITELISTED.call();
        //ADMIN = await token.ROLE_ADMIN.call();
    });

    it("Rejects unprivileged transfer", async () => {
        const initialBalance = await token.balanceOf.call(user, {from: user});
         await util.assertReverts(token.transfer(user, 1, {from: user}));
        const balance = await token.balanceOf.call(user);
        assert(balance.equals(initialBalance));
    });

    it("Rejects unprivileged approve", async () => {
        const initialBalance = await token.balanceOf.call(user);
        await util.assertReverts(token.approve(user, 1, {from: user}));
        const balance = await token.balanceOf.call(user);
        // TODO: Assert correct state
        assert(balance.equals(initialBalance));
    });

    it("Rejects unprivileged transferFrom", async () => {
        const initialBalance = await token.balanceOf.call(user, {from: user});
        await util.assertReverts(token.transferFrom(user, user2, 1, {from: user}));
        const balance = await token.balanceOf.call(user);
        assert(balance.equals(initialBalance));
    });

//});


        // it('should not allow non owner to burn tokens', async () => {
        //     await token.mint(whitelisted, 10, { from: owner }); // seed the account so we can try and burn it.
        //     const initialBalance = await token.balanceOf.call(whitelisted);
        //     try {
        //         await token.burn(1, { from: whitelisted }); // burning is always done from the owners account to respect privacy of token holders
        //         throw ERROR;
        //     } catch (error) {
        //         if (!isSolidityError(error)) throw error;
        //         const balance = await token.balanceOf.call(whitelisted);
        //         assert.equal(balance.toNumber(), initialBalance.toNumber());
        //     }
        // });
    });

    // describe('ERC20 Whitelisted functionality', function() {
    //     it('should not allow transfer tokens to non whitelisted address', async () => {
    //         try {
    //             await token.transfer(user, 10, { from: owner });
    //             throw ERROR;
    //         } catch (error) {
    //             if (!isSolidityError(error)) throw error;
    //             const balance = await token.balanceOf.call(user);
    //             assert.equal(balance, 0);
    //         }
    //     });

    //     it('should transfer tokens to whitelisted address', async () => {
    //         const initialBalance = await token.balanceOf.call(whitelisted);
    //         await token.transfer(whitelisted, 10, { from: owner });
    //         const balance = await token.balanceOf.call(whitelisted);
    //         assert.equal(balance.toNumber(), initialBalance.toNumber() + 10);
    //     });

    //     it('should not approve non whitelisted spender', async () => {
    //         const initialAllowance = await token.allowance.call(owner, user);
    //         try {
    //             await token.approve(user, 10, { from: owner });
    //             throw ERROR;
    //         } catch (error) {
    //             if (!isSolidityError(error)) throw error;
    //             const allowance = await token.allowance.call(owner, user);
    //             assert.equal(allowance.toNumber(), initialAllowance.toNumber());
    //         }
    //     });

    //     it('should approve whitelisted spender', async () => {
    //         const initialAllowance = await token.allowance.call(owner, whitelisted);
    //         await token.approve(whitelisted, 500, { from: owner });
    //         const allowance = await token.allowance.call(owner, whitelisted);
    //         assert.equal(allowance.toNumber(), initialAllowance.toNumber() + 500);
    //     });

    //     it('should transferFrom to whitelisted address', async () => {
    //         const initialBalance = await token.balanceOf.call(whitelisted);
    //         await token.transferFrom(owner, whitelisted, 100, { from: whitelisted });
    //         const balance = await token.balanceOf.call(whitelisted);
    //         assert.equal(balance.toNumber(), initialBalance.toNumber() + 100);
    //     });

    //     it('should not transferFrom a banned address', async () => {
    //         const initialBalance = await token.balanceOf.call(whitelisted);
    //         await token.removeFromWhitelist(whitelisted, { from: admin });
    //         try {
    //             await token.transferFrom(owner, whitelisted, 100, { from: whitelisted });
    //             throw ERROR;
    //         } catch (error) {
    //             if (!isSolidityError(error)) throw error;
    //             const balance = await token.balanceOf.call(whitelisted);
    //             assert.equal(initialBalance.toNumber(), balance.toNumber());
    //             await token.addToWhitelist(whitelisted, { from: admin }); // add back to whitelist for next test
    //         }
    //     });
    // });

    // describe('Whitelist Disabled', function() {
    //     after(async () => {
    //         await token.enableWhitelist(true, { from: owner });
    //     });

    //     it('should not allow non owner to disable whitelist', async () => {
    //         try {
    //             await token.enableWhitelist(false, { from: admin });
    //             throw ERROR;
    //         } catch (error) {
    //             if (!isSolidityError(error)) throw error;
    //             const isWhitelisted = await token.isWhitelisted.call();
    //             assert.equal(isWhitelisted, true);
    //         }
    //     });

    //     it('should disable whitelist', async () => {
    //         await token.enableWhitelist(false, { from: owner });
    //         const isWhitelisted = await token.isWhitelisted.call();
    //         assert.equal(isWhitelisted, false);
    //     });

    //     it('should transfer with whitelist disabled', async () => {
    //         const initialBalance = await token.balanceOf.call(user);
    //         await token.transfer(user, 1000, { from: owner });
    //         const balance = await token.balanceOf.call(user);
    //         assert.equal(balance.toNumber(), initialBalance.toNumber() + 1000);
    //     });

    //     it('should approve with whitelist disabled', async () => {
    //         const initialAllowance = await token.allowance.call(whitelisted, user);
    //         await token.approve(user, 1, { from: whitelisted });
    //         const allowance = await token.allowance.call(whitelisted, user);
    //         assert.equal(allowance.toNumber(), initialAllowance.toNumber() + 1);
    //     });

    //     it('should transferFrom with whitelist disabled', async () => {
    //         const initialBalance = await token.balanceOf.call(user);
    //         await token.transferFrom(whitelisted, user, 1, { from: user });
    //         const balance = await token.balanceOf.call(user);
    //         assert.equal(balance.toNumber(), initialBalance.toNumber() + 1);
    //     });
    // });
//});
    // describe('Whitelist management', function() {
    //     it('should add an admin by owner', async () => {
    //         let isAdmin = await token.hasRole.call(admin, ADMIN);
    //         assert.equal(isAdmin, false);
    //         await token.addAdmin(admin, { from: owner });
    //         isAdmin = await token.hasRole.call(admin, ADMIN);
    //         assert.equal(isAdmin, true);
    //     });

    //     it('should not allow non owner to add admin', async() => {
    //         let isAdmin = await token.hasRole.call(user, ADMIN); // not even an elevated admin can do this.
    //         assert.equal(isAdmin, false);
    //         try {
    //             await token.addAdmin(user, { from: admin }); // will throw because of permissions issue
    //             throw ERROR;
    //         } catch (error) {
    //             if (!isSolidityError(error)) throw error;
    //             isAdmin = await token.hasRole.call(user, ADMIN);
    //             assert.equal(isAdmin, false);
    //         }
    //     });

    //     it('should add user to whitelist', async () => {
    //         let isWhitelisted = await token.hasRole.call(whitelisted, WHITELISTED);
    //         assert.equal(isWhitelisted, false);
    //         await token.addToWhitelist(whitelisted, { from: admin });
    //         isWhitelisted = await token.hasRole.call(whitelisted, WHITELISTED);
    //         assert.equal(isWhitelisted, true);
    //     });

    //     it('should not allow none admins to add to whitelist', async () => {
    //         let isWhitelisted = await token.hasRole.call(user, WHITELISTED);
    //         assert.equal(isWhitelisted, false);
    //         try {
    //             await token.addToWhitelist(user, { from: owner }); // not even owner is admin by default (can elevate himself...)
    //             throw ERROR;
    //         } catch (error) {
    //             if (!isSolidityError(error)) throw error;
    //             isWhitelisted = await token.hasRole.call(user, WHITELISTED);
    //             assert.equal(isWhitelisted, false);
    //         }
    //     });

    //     it('should remove admin', async () => {
    //         let isAdmin = await token.hasRole.call(admin, ADMIN);
    //         assert.equal(isAdmin, true);
    //         await token.removeAdmin(admin, { from: owner });
    //         isAdmin = await token.hasRole.call(admin, ADMIN);
    //         assert.equal(isAdmin, false);
    //         await token.addAdmin(admin, { from: owner });
    //         isAdmin = await token.hasRole.call(admin, ADMIN);
    //         assert.equal(isAdmin, true);
    //     });

    //     it('should not allow none owners to remove admin', async () => {
    //         let isAdmin = await token.hasRole.call(admin, ADMIN);
    //         assert.equal(isAdmin, true);
    //         try {
    //             await token.removeAdmin(admin, { from: user });
    //             throw ERROR;
    //         } catch (error) {
    //             if (!isSolidityError(error)) throw error;
    //             isAdmin = await token.hasRole.call(admin, ADMIN);
    //             assert.equal(isAdmin, true);
    //         }
    //     });

    //     it('should remove from whitelist', async () => {
    //         let isWhitelisted = await token.hasRole.call(whitelisted, WHITELISTED);
    //         assert.equal(isWhitelisted, true);
    //         await token.removeFromWhitelist(whitelisted, { from: admin });
    //         isWhitelisted = await token.hasRole.call(whitelisted, WHITELISTED);
    //         assert.equal(isWhitelisted, false);
    //         token.addToWhitelist(whitelisted, { from: admin });
    //     });

    //     it('should not allow non admin to remove from whitelist', async () => {
    //         let isWhitelisted = await token.hasRole.call(whitelisted, WHITELISTED);
    //         assert.equal(isWhitelisted, true);
    //         try {
    //             await token.removeFromWhitelist(whitelisted, { from: owner });
    //             throw ERROR;
    //         } catch (error) {
    //             if (!isSolidityError(error)) throw error;
    //             isWhitelisted = await token.hasRole.call(whitelisted, WHITELISTED);
    //             assert.equal(isWhitelisted, true);
    //         }
    //     });
    // });

