'use strict'

async function upgradeToken (
  tokenManager, oldToken, newToken,
  tokenManagerOwner, oldTokenOwner
) {
  const oldTokenName = await oldToken.name()
  const newTokenName = await newToken.name()

  if (oldTokenName !== newTokenName) {
    throw Error('token names are not the same')
  }

  await oldToken.upgrade(newToken.address, { from: oldTokenOwner });
  await tokenManager.upgradeToken(newTokenName, newToken.address, { from: tokenManagerOwner });
}

module.exports = upgradeToken
