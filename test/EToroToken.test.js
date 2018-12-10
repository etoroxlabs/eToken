'use strict';

const util = require("./utils.js");

const Whitelist = artifacts.require("Whitelist");
const ExternalERC20Storage = artifacts.require("ExternalERC20Storage");
const EToroTokenMock = artifacts.require("EToroTokenMock");

const ERROR = new Error('should not have reached this');
const isSolidityError = (e) => e.message === 'VM Exception while processing transaction: revert';

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('EToro Token',  async function(
    [owner, minter, pauser, burner, whitelistAdmin,
     whitelisted, whitelisted1, user, user1, ...restAccounts]) {

    beforeEach(async function() {
        const whitelist = await Whitelist.new({from: owner});

        // Create a token token
        const token = await EToroTokenMock.new("eUSD", "e", 1000,
                                               whitelist.address,
                                               {from: owner});

        // Setup permissions
        await token.addMinter(minter, {from: owner});
        await token.addPauser(pauser, {from: owner});
        await token.addBurner(burner, {from: owner});
        await whitelist.addWhitelistAdmin(whitelistAdmin, {from: owner});
        await whitelist.addWhitelisted(whitelisted, {from: owner});
        await whitelist.addWhitelisted(whitelisted1, {from: owner});

        // Set test state
        this.whitelist = whitelist;
        this.token = token;
        this.local = {};
    });

    async function tokenIsInitiallyEmpty(t) {
        const initialBalance = await t.token.balanceOf.call(owner, {from: owner});
        const initialSupply = await t.token.totalSupply.call({from: owner});
        assert(initialBalance.equals(0));
        assert(initialSupply.equals(0));
        t.local.curBalance = initialBalance;
        t.local.curSupply = initialSupply;
    }

    async function mintAndVerify(t, amount) {
        await t.token.mint(owner, amount, {from: owner});

        const balance = await t.token.balanceOf.call(owner);
        const supply = await t.token.totalSupply.call();

        assert(balance.equals(t.local.curBalance.plus(amount)));
        assert(supply.equals(t.local.curSupply.plus(amount)));

        t.local.curBalance = balance;
        t.local.curSupply = supply;
    }


    describe("Basic tests", async function() {
        

        describe('Minting and Burning', function() {
            it('should mint new tokens', async function() {
                const mintVal = 1000;
                await tokenIsInitiallyEmpty(this);
                await mintAndVerify(this, mintVal);
            });

            it('should burn tokens', async function() {
                const burnVal = 500;
                await tokenIsInitiallyEmpty(this);
                await mintAndVerify(this, 1000);
                await this.token.burn(burnVal, { from: owner });
                const balance = await this.token.balanceOf.call(owner, {from: owner});
                const supply = await this.token.totalSupply.call({from: owner});
                assert(balance.equals(this.local.curBalance.minus(burnVal)));
                assert(supply.equals(this.local.curSupply.minus(burnVal)));
            });

            it('should not allow non minter to mint tokens', async function() {
                const initialBalance = await this.token.balanceOf.call(user);
                util.assertReverts(this.token.mint(user, 1, {from: user}));
                const balance = await this.token.balanceOf.call(user);
                assert(balance.equals(initialBalance));
            });

            it('should allow burnFrom', async function() {
                const burnVal = 100;
                await this.token.mint(whitelisted, burnVal, {from: owner});
                (await this.token.totalSupply()).should.be.bignumber.equal(burnVal);
                (await this.token.balanceOf(whitelisted)).should.be.bignumber.equal(burnVal);

                await this.token.approve(owner, burnVal, {from: whitelisted});
                await this.token.burnFrom(whitelisted, burnVal, {from: owner});

                (await this.token.totalSupply()).should.be.bignumber.equal(0);
            });
        });

        describe('Transfer', function() {

            it('should perform transfer', async function() {
                const burnVal = 100;
                await this.token.mint(whitelisted, burnVal, {from: owner});
                (await this.token.totalSupply()).should.be.bignumber.equal(burnVal);

                (await this.token.balanceOf(whitelisted)).should.be.bignumber.equal(burnVal);
                (await this.token.balanceOf(whitelisted1)).should.be.bignumber.equal(0);

                await this.token.transfer(whitelisted1, 50, {from: whitelisted});

                (await this.token.balanceOf(whitelisted)).should.be.bignumber.equal(50);
                (await this.token.balanceOf(whitelisted1)).should.be.bignumber.equal(50);
                (await this.token.totalSupply()).should.be.bignumber.equal(burnVal);
            });

            it('should perform transferFrom', async function() {
                const burnVal = 100;
                await this.token.mint(owner, burnVal, {from: owner});
                (await this.token.totalSupply()).should.be.bignumber.equal(burnVal);

                (await this.token.balanceOf(owner)).should.be.bignumber.equal(burnVal);
                (await this.token.balanceOf(whitelisted)).should.be.bignumber.equal(0);
                (await this.token.balanceOf(whitelisted1)).should.be.bignumber.equal(0);

                await this.token.approve(whitelisted, 50, {from: owner})
                await this.token.transferFrom(owner, whitelisted1, 50, {from: whitelisted});
                await util.assertReverts(this.token.transferFrom(owner, whitelisted1, 1, {from: whitelisted}));

                (await this.token.balanceOf(owner)).should.be.bignumber.equal(50);
                (await this.token.balanceOf(whitelisted)).should.be.bignumber.equal(0);
                (await this.token.balanceOf(whitelisted1)).should.be.bignumber.equal(50);
                (await this.token.totalSupply()).should.be.bignumber.equal(burnVal);
            });
        })

        describe('Allowance', function() {

            it('should perform increaseAllowance', async function() {
                const mintVal = 100;
                await this.token.mint(whitelisted, mintVal, {from: owner});
                (await this.token.totalSupply()).should.be.bignumber.equal(mintVal);
                (await this.token.balanceOf(whitelisted)).should.be.bignumber.equal(mintVal);

                await this.token.approve(owner, 20, {from: whitelisted});
                (await this.token.allowance(whitelisted, owner)).should.be.bignumber.equal(20);
                await this.token.increaseAllowance(owner, 80, {from: whitelisted});
                (await this.token.allowance(whitelisted, owner)).should.be.bignumber.equal(mintVal);
            });

            it('should perform decreaseAllowance', async function() {
                const mintVal = 100;
                await this.token.mint(whitelisted, mintVal, {from: owner});
                (await this.token.totalSupply()).should.be.bignumber.equal(mintVal);
                (await this.token.balanceOf(whitelisted)).should.be.bignumber.equal(mintVal);

                await this.token.approve(owner, 20, {from: whitelisted});
                (await this.token.allowance(whitelisted, owner)).should.be.bignumber.equal(20);
                await this.token.decreaseAllowance(owner, 5, {from: whitelisted});
                (await this.token.allowance(whitelisted, owner)).should.be.bignumber.equal(15);
            });
        });
    });

    describe("default permissions", function() {
        it("Rejects unprivileged transfer when both are non-whitelisted", async function() {
            const initialBalance = await this.token.balanceOf(user);
            await util.assertReverts(this.token.transfer(user, 1, {from: user}));
            const balance = await this.token.balanceOf(user);
            assert(balance.equals(initialBalance));
        });

        it("Rejects unprivileged transfer when receiver are non-whitelisted", async function() {
            await this.token.mint(whitelisted, 100, {from: owner});
            const initialBalance = await this.token.balanceOf(whitelisted);
            await util.assertReverts(this.token.transfer(user, 10, {from: whitelisted}));
            const balance = await this.token.balanceOf(whitelisted);
            assert(balance.equals(initialBalance));
        })

        it("Rejects unprivileged transfer when transmitter are non-whitelisted", async function() {
            await this.token.mint(user, 100, {from: owner});
            const initialBalance = await this.token.balanceOf(user);
            await util.assertReverts(this.token.transfer(whitelisted, 10, {from: user}));
            const balance = await this.token.balanceOf(user);
            assert(balance.equals(initialBalance));
        })

        it("Rejects unprivileged approve", async function() {
            const initialBalance = await this.token.balanceOf(user);
            await util.assertReverts(this.token.approve(user, 1, {from: user}));
            const balance = await this.token.balanceOf(user);
            // TODO: Assert correct state
            assert(balance.equals(initialBalance));
        });

        it("Rejects unprivileged transferFrom", async function() {
            const initialBalance = await this.token.balanceOf(user, {from: user});
            await util.assertReverts(this.token.transferFrom(user, user1, 1, {from: user}));
            const balance = await this.token.balanceOf(user);
            assert(balance.equals(initialBalance));
        });

        it("Rejects unprivileged burn", async function() {
            const burnVal = 100;
            await this.token.mint(whitelisted, burnVal, {from: owner});
            (await this.token.totalSupply()).should.be.bignumber.equal(burnVal);
            (await this.token.balanceOf(whitelisted)).should.be.bignumber.equal(burnVal);

            await util.assertReverts(this.token.burn(burnVal, {from: whitelisted}));

            (await this.token.totalSupply()).should.be.bignumber.equal(burnVal);
        });

        it("Rejects unprivileged burnFrom", async function() {
            const burnVal = 100;
            await tokenIsInitiallyEmpty(this);
            await mintAndVerify(this, burnVal);

            await this.token.approve(whitelisted, burnVal, {from: owner});
            await util.assertReverts(this.token.burnFrom(owner, burnVal, {from: whitelisted}));

            (await this.token.totalSupply()).should.be.bignumber.equal(burnVal);
        });

        it("Rejects unprivileged increaseAllowance", async function() {
            const mintVal = 100;
            await this.token.mint(user, mintVal, {from: owner});
            (await this.token.totalSupply()).should.be.bignumber.equal(mintVal);
            (await this.token.balanceOf(user)).should.be.bignumber.equal(mintVal);

            (await this.token.allowance(user, whitelisted)).should.be.bignumber.equal(0);
            await util.assertReverts(this.token.increaseAllowance(whitelisted, 5, {from: user}));
            (await this.token.allowance(user, whitelisted)).should.be.bignumber.equal(0);
        });

        it("Rejects unprivileged decreaseAllowance", async function() {
            const mintVal = 100;
            await this.token.mint(user, mintVal, {from: owner});
            (await this.token.totalSupply()).should.be.bignumber.equal(mintVal);
            (await this.token.balanceOf(user)).should.be.bignumber.equal(mintVal);

            (await this.token.allowance(user, whitelisted)).should.be.bignumber.equal(0);
            await util.assertReverts(this.token.decreaseAllowance(whitelisted, 5, {from: user}));
            (await this.token.allowance(user, whitelisted)).should.be.bignumber.equal(0);
        });
    });

    describe("upgradability", function() {

        async function upgradeAndCheck(initialToken, upgradeToken, checks) {
            (await initialToken.isUpgraded()).should.be.equal(false);
            (await upgradeToken.isUpgraded()).should.be.equal(false);
            (await initialToken.upgradedToken()).should.be.equal(util.ZERO_ADDRESS);
            (await upgradeToken.upgradedToken()).should.be.equal(util.ZERO_ADDRESS);
            
            await initialToken.upgrade(upgradeToken.address, {from: owner});

            (await initialToken.upgradedToken()).should.be.equal(upgradeToken.address);
            (await upgradeToken.upgradedToken()).should.be.equal(util.ZERO_ADDRESS);
            (await initialToken.isUpgraded()).should.be.equal(true);
            (await upgradeToken.isUpgraded()).should.be.equal(false);
        }

        describe("when owner", function() {
            it("is not upgraded", async function() {
                (await this.token.isUpgraded()).should.be.equal(false);
            });

            it("allow upgrading and correct balanceOf", async function() {
                const initialToken = this.token;
                await initialToken.mint(owner, 80, {from: owner});

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                (await initialToken.balanceOf(owner)).should.be.bignumber.equal(80);
                (await upgradeToken.balanceOf(owner)).should.be.bignumber.equal(0);

                await upgradeAndCheck(initialToken, upgradeToken);

                (await initialToken.balanceOf(owner)).should.be.bignumber.equal(0);
                (await upgradeToken.balanceOf(owner)).should.be.bignumber.equal(0);
            });

            it("reject if already upgraded", async function() {

                const initialToken = this.token;

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                const upgradeToken2 = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                await upgradeAndCheck(initialToken, upgradeToken);
                await util.assertReverts(initialToken.upgrade(upgradeToken2.address, {from: owner}));
                (await initialToken.upgradedToken()).should.be.equal(upgradeToken.address);
            })

            it("reject if upgrading itself", async function() {

                const initialToken = this.token;

                await util.assertReverts(initialToken.upgrade(initialToken.address, {from: owner}));
                (await initialToken.upgradedToken()).should.be.equal(util.ZERO_ADDRESS);
            })

            it("reject if upgrading zero address", async function() {

                const initialToken = this.token;

                await util.assertReverts(initialToken.upgrade(util.ZERO_ADDRESS, {from: owner}));
                (await initialToken.upgradedToken()).should.be.equal(util.ZERO_ADDRESS);
            })

            it("should upgrade name", async function() {
                const initialToken = this.token;

                const newName = "new"

                const upgradeToken = await EToroTokenMock.new(
                    newName, "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                (await this.token.name()).should.not.be.equal(newName);
                (await initialToken.name()).should.be.equal(await this.token.name());
                (await upgradeToken.name()).should.be.equal(newName);

                await upgradeAndCheck(initialToken, upgradeToken);

                (await initialToken.name()).should.be.equal(newName);
                (await upgradeToken.name()).should.be.equal(newName);
            })

            it("should upgrade symbol", async function() {
                const initialToken = this.token;

                const newSymbol = "new"

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", newSymbol, 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                (await this.token.symbol()).should.not.be.equal(newSymbol);
                (await initialToken.symbol()).should.be.equal(await this.token.symbol());
                (await upgradeToken.symbol()).should.be.equal(newSymbol);

                await upgradeAndCheck(initialToken, upgradeToken);

                (await initialToken.symbol()).should.be.equal(newSymbol);
                (await upgradeToken.symbol()).should.be.equal(newSymbol);
            })

            it("should upgrade decimals", async function() {
                const initialToken = this.token;

                const newDecimals = 8

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", newDecimals,
                    this.whitelist.address,
                    {from: owner}
                );

                (await this.token.decimals()).should.not.be.bignumber.equal(newDecimals);
                (await initialToken.decimals()).should.be.bignumber.equal(await this.token.decimals());
                (await upgradeToken.decimals()).should.be.bignumber.equal(newDecimals);

                await upgradeAndCheck(initialToken, upgradeToken);

                (await initialToken.decimals()).should.be.bignumber.equal(newDecimals);
                (await upgradeToken.decimals()).should.be.bignumber.equal(newDecimals);
            })

            it("should upgrade totalSupply", async function() {
                const initialToken = this.token;

                const newTotalSupply = 80

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                await upgradeToken.mint(owner, newTotalSupply, {from: owner});

                (await this.token.totalSupply()).should.not.be.bignumber.equal(newTotalSupply);
                (await initialToken.totalSupply()).should.be.bignumber.equal(await this.token.totalSupply());
                (await upgradeToken.totalSupply()).should.be.bignumber.equal(newTotalSupply);

                await upgradeAndCheck(initialToken, upgradeToken);

                (await initialToken.totalSupply()).should.be.bignumber.equal(newTotalSupply);
                (await upgradeToken.totalSupply()).should.be.bignumber.equal(newTotalSupply);
            })

            it("should upgrade allowance", async function() {
                const initialToken = this.token;

                const newAllowance = 80

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                await upgradeToken.mint(owner, newAllowance, {from: owner});
                await upgradeToken.approve(whitelisted, newAllowance, {from: owner});

                (await this.token.allowance(owner, whitelisted)).should.not.be.bignumber.equal(newAllowance);
                (await initialToken.allowance(owner, whitelisted)).should.be.bignumber.equal(0);
                (await upgradeToken.allowance(owner, whitelisted)).should.be.bignumber.equal(newAllowance);

                await upgradeAndCheck(initialToken, upgradeToken);

                (await initialToken.allowance(owner, whitelisted)).should.be.bignumber.equal(newAllowance);
                (await upgradeToken.allowance(owner, whitelisted)).should.be.bignumber.equal(newAllowance);
            })

            it("should revert transfer", async function() {
                const initialToken = this.token;

                const newAllowance = 80

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                await upgradeAndCheck(initialToken, upgradeToken);

                await util.assertReverts(
                    initialToken.transfer(owner, 2000, {from: whitelisted})
                );
            })

            it("should revert approve", async function() {
                const initialToken = this.token;

                const newAllowance = 80

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                await upgradeAndCheck(initialToken, upgradeToken);

                await util.assertReverts(
                    initialToken.approve(owner, 2000, {from: whitelisted})
                );
            })

            it("should revert transferFrom", async function() {
                const initialToken = this.token;

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                await upgradeAndCheck(initialToken, upgradeToken);

                await util.assertReverts(
                    initialToken.transferFrom(owner, whitelisted1, 80, {from: whitelisted})
                );
            })

            it("should revert mint", async function() {
                const initialToken = this.token;

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                await upgradeAndCheck(initialToken, upgradeToken);

                await util.assertReverts(
                    initialToken.mint(owner, 80, {from: owner})
                );
            })

            it("should revert burn", async function() {
                const initialToken = this.token;

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                await upgradeAndCheck(initialToken, upgradeToken);

                await util.assertReverts(
                    initialToken.burn(80, {from: owner})
                );
            })

            it("should revert burnFrom", async function() {
                const initialToken = this.token;

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                await upgradeAndCheck(initialToken, upgradeToken);

                await util.assertReverts(
                    initialToken.burnFrom(owner, 80, {from: owner})
                );
            })

            it("should revert increaseAllowance", async function() {
                const initialToken = this.token;

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                await upgradeAndCheck(initialToken, upgradeToken);

                await util.assertReverts(
                    initialToken.increaseAllowance(owner, 80, {from: owner})
                );
            })

            it("should revert decreaseAllowance", async function() {
                const initialToken = this.token;

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                await upgradeAndCheck(initialToken, upgradeToken);

                await util.assertReverts(
                    initialToken.decreaseAllowance(owner, 80, {from: owner})
                );
            })
        });

        describe("when not owner", function() {
            it("should reject upgrading", async function() {
                const initialToken = this.token;

                const upgradeToken = await EToroTokenMock.new(
                    "eUSD", "e", 1000,
                    this.whitelist.address,
                    {from: owner}
                );

                (await initialToken.isUpgraded()).should.be.equal(false);
                (await initialToken.upgradedToken()).should.be.equal(util.ZERO_ADDRESS);

                await util.assertReverts(initialToken.upgrade(upgradeToken.address, {from: whitelisted}));
                
                (await initialToken.isUpgraded()).should.be.equal(false);
                (await initialToken.upgradedToken()).should.be.equal(util.ZERO_ADDRESS);
            });
        });
    });
});
