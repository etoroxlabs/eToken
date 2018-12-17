/* global artifacts, contract */
/* eslint-env mocha */

const { shouldBehaveLikePublicRole } = require('./behaviors/PublicRole.behavior');
const MinterRoleMock = artifacts.require('MinterRoleMock');

contract('MinterRole', function ([_, minter, otherMinter, ...otherAccounts]) {
  beforeEach(async function () {
    this.contract = await MinterRoleMock.new({ from: minter });
    await this.contract.addMinter(otherMinter, { from: minter });
  });

  shouldBehaveLikePublicRole(minter, otherMinter, otherAccounts, 'minter');
});
