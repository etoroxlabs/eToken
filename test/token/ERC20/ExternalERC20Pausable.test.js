const { shouldBehaveLikeERC20Pausable } = require('./behaviors/ERC20Pausable.behavior');

const ExternalERC20PausableMock = artifacts.require('ExternalERC20PausableMock');

contract('ExternalERC20Pausable', function ([_, pauser, otherPauser, recipient, anotherAccount, ...otherAccounts]) {
  beforeEach(async function () {
    this.token = await ExternalERC20PausableMock.new(pauser, 100, { from: pauser });
  });

  shouldBehaveLikeERC20Pausable(pauser, otherPauser, recipient, anotherAccount, otherAccounts);
});
