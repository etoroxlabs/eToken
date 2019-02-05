/* global artifacts, contract */
/* eslint-env mocha */

const { shouldBehaveLikePublicRole } = require('./behaviors/PublicRole.behavior');
const WhitelistAdminRoleMock = artifacts.require('WhitelistAdminRoleMock');

contract('WhitelistAdminRole', function (
  [_, whitelistAdmin, otherWhitelistAdmin, ...otherAccounts]) {
  beforeEach(async function () {
    this.contract = await WhitelistAdminRoleMock.new({ from: whitelistAdmin });
    await this.contract.addWhitelistAdmin(otherWhitelistAdmin,
                                          { from: whitelistAdmin });
  });

  shouldBehaveLikePublicRole(whitelistAdmin, otherWhitelistAdmin, otherAccounts,
                             'whitelistAdmin');
});
