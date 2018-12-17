/* global artifacts, contract */
/* eslint-env mocha */

const { shouldBehaveLikePublicRole } = require('./behaviors/PublicRole.behavior');
const BurnerRoleMock = artifacts.require('BurnerRoleMock');

contract('BurnerRole', function ([_, burner, otherBurner, ...otherAccounts]) {
  beforeEach(async function () {
    this.contract = await BurnerRoleMock.new({ from: burner });
    await this.contract.addBurner(otherBurner, { from: burner });
  });

  shouldBehaveLikePublicRole(burner, otherBurner, otherAccounts, 'burner');
});
