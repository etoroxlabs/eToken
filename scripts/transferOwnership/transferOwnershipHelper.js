'use strict';

async function transferOwnershipHelper (ownerAddress, newOwnerAddress, ownableContracts) {
  ownableContracts.forEach((t, index) => {
    if (typeof t.transferOwnership !== 'function') {
      throw Error(`The contract no. ${index} is not ownable`);
    }
  });

  const owners = await Promise.all(ownableContracts.map(t => t.owner()));

  owners.forEach((owner, index) => {
    if (owner !== ownerAddress) {
      throw Error(`The contract no. ${index} is not owned by you`);
    }
  });

  for (const [index, t] of ownableContracts.entries()) {
    try {
      await t.transferOwnership(newOwnerAddress, { from: ownerAddress });
    } catch (e) {
      console.error(`Error in contract no. ${index}`);
      throw e;
    }
  }
}

module.exports = transferOwnershipHelper;
