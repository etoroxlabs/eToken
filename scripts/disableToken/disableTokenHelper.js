'use strict';

const oneAddress = '0x1111111111111111111111111111111111111111';

async function disableToken (DisableTokenArtifact, token, tokenOwner) {
  const disableToken = await DisableTokenArtifact.new({ from: tokenOwner });

  await token.pause({ from: tokenOwner });
  await token.upgrade(disableToken.address, { from: tokenOwner });
  await token.transferOwnership(oneAddress, { from: tokenOwner });
}

module.exports = disableToken;
