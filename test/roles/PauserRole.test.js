/* global artifacts, contract */
/* eslint-env mocha */

const { shouldBehaveLikePublicRole } = require('./behaviors/PublicRole.behavior');
const PauserRoleMock = artifacts.require('PauserRoleMock');

contract('PauserRole', function ([_, pauser, otherPauser, ...otherAccounts]) {
  beforeEach(async function () {
    this.contract = await PauserRoleMock.new({ from: pauser });
    await this.contract.addPauser(otherPauser, { from: pauser });
  });

  shouldBehaveLikePublicRole(pauser, otherPauser, otherAccounts, 'pauser');
});
