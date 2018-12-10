/* global artifacts, web3 */

const Whitelist = artifacts.require('Whitelist')
const TokenManager = artifacts.require('TokenManager')
const EToroToken = artifacts.require('EToroToken')
const ExternalERC20Storage = artifacts.require('ExternalERC20Storage')

module.exports = function (deployer, _network, accounts) {

  if (deployer.network === 'development' ||
      deployer.network === 'develop') {
    deployer.then(() => setupAccounts(accounts))
  }
}

async function setupAccounts ([owner, whitelistAdmin, whitelisted, ...restAccounts]) {

  /*
    The purpose of this is to automatically setup the test environment accounts.
    DO NOT use in production yet.
  */

  const intialMintValue = '100'

  // Setup whitelists
  const whitelistContract = await Whitelist.deployed()

  await whitelistContract.addWhitelistAdmin(whitelistAdmin, { from: owner })
  await whitelistContract.addWhitelisted(whitelisted, { from: whitelistAdmin })

  // Setup tokens
  const tokenManagerContract = await TokenManager.deployed()

  const tokenDetails = [
    {
      name: 'eToro US Dollar',
      symbol: 'eUSD',
      decimals: 4
    },
    {
      name: 'eToro Australian Dollar',
      symbol: 'eAUD',
      decimals: 4
    }
  ]

  const tokens = await Promise.all(
    tokenDetails.map(async (td) => {
      const externalERC20Storage = await ExternalERC20Storage.new()
      const token = await EToroToken.new(
        td.name, td.symbol, td.decimals,
        whitelistContract.address, externalERC20Storage.address,
        { from: owner }
      )
      await tokenManagerContract.addToken(td.name, token.address)

      const tokenAddress = await tokenManagerContract.getToken(td.name, { from: owner })
      await externalERC20Storage.transferImplementor(tokenAddress, { from: owner })

      return EToroToken.at(tokenAddress)
    })
  )

  // Mint tokens
  await Promise.all(
    tokens.map((t) => t.mint(owner, intialMintValue, { from: owner }))
  )
};
