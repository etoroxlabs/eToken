/* global artifacts, contract */
/* eslint-env mocha */

const { shouldBehaveLikePublicRole } = require('./behaviors/PublicRole.behavior');
const MinterRoleMock = artifacts.require('MinterRoleMock');

contract('MinterRole', function ([_, minter, otherMinter, ...otherAccounts]) {
  beforeEach(async function () {
    this.contract = await MinterRoleMock.new({ from: minter });
    [minter, otherMinter].forEach(
      async (x) => this.contract.addMinter(x, { from: minter }));
  });

  shouldBehaveLikePublicRole(minter, otherMinter, otherAccounts, 'minter');
});
