/* global artifacts, contract */
/* eslint-env mocha */

const { shouldBehaveLikeERC20Pausable } = require('./behaviors/ERC20Pausable.behavior');

const ExternalERC20PausableMock = artifacts.require('ExternalERC20PausableMock');
const ExternalERC20Storage = artifacts.require('ExternalERC20Storage');

contract('ExternalERC20Pausable', function ([_, pauser, otherPauser, recipient, anotherAccount, ...otherAccounts]) {
  beforeEach(async function () {
    const storage = await ExternalERC20Storage.new({ from: pauser });
    this.token = await ExternalERC20PausableMock.new(pauser, 100,
                                                     storage.address,
                                                     { from: pauser });
  });

  shouldBehaveLikeERC20Pausable(pauser, otherPauser, recipient, anotherAccount, otherAccounts);
});
