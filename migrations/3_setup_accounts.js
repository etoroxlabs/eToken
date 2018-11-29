
const Whitelist = artifacts.require("Whitelist");
const TokenManager = artifacts.require("TokenManager");
const EToroToken = artifacts.require("EToroToken");

async function setup_accounts(deployer, _network, accounts) {

  /*
    The purpose of this is to automatically setup the test environment accounts.
    DO NOT use in production yet.
  */

  if (deployer.network == 'development' ||
      deployer.network == 'develop') {

    const owner = accounts[0];
    const whitelistAdmin = accounts[1];
    const whitelisted = accounts[2];

    const intialMintValue = "100";

    // Setup whitelists
    const whitelistContract = await Whitelist.deployed();
    
    await whitelistContract.addWhitelistAdmin(whitelistAdmin, { from: owner });
    await whitelistContract.addWhitelisted(whitelisted, { from: whitelistAdmin });

    // Setup tokens
    const tokenManagerContract = await TokenManager.deployed();

    const tokenDetails = [
      {
        name: "eToro US Dollar",
        symbol: "eUSD",
        decimals: 4
      },
      {
        name: "eToro Australian Dollar",
        symbol: "eAUD",
        decimals: 4
      }
    ];

    const tokensNew = await Promise.all(
      tokenDetails.map((td) =>
        tokenManagerContract.newToken(td.name, td.symbol, td.decimals, whitelistContract.address, { from: owner })
      )
    )

    const tokens = await Promise.all(
      tokenDetails.map(async (td) =>
        EToroToken.at(await tokenManagerContract.getToken(td.name, {from: owner}))
      )
    );

    // Mint tokens
    await Promise.all(
      tokens.map((t) => {
        t.mint(owner, intialMintValue, { from: owner });
      })
    );
  }
};

module.exports = (deployer, _network, accounts) => {
  deployer.then(async () => await setup_accounts(deployer, _network, accounts));
}