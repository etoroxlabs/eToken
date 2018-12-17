/* global artifacts, contract */
/* eslint-env mocha */

const { shouldBehaveLikePublicRole } = require('./behaviors/PublicRole.behavior');
const BlacklistAdminRoleMock = artifacts.require('BlacklistAdminRoleMock');

contract('BlacklistAdminRole', function ([_, blacklistAdmin,
  otherBlacklistAdmin,
  ...otherAccounts]) {
  beforeEach(async function () {
    this.contract = await BlacklistAdminRoleMock.new({ from: blacklistAdmin });
    await this.contract.addBlacklistAdmin(otherBlacklistAdmin,
      { from: blacklistAdmin });
  });

  shouldBehaveLikePublicRole(blacklistAdmin, otherBlacklistAdmin, otherAccounts,
    'blacklistAdmin');
});
