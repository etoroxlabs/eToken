const { shouldBehaveLikeERC20PublicAPI } = require('./ERC20.public.behavior.js')
const { shouldBehaveLikeERC20InternalAPI } = require('./ERC20.internal.behavior.js')

function shouldBehaveLikeERC20 (owner, recipient, anotherAccount) {
  describe('ERC20 public API', function () {
    shouldBehaveLikeERC20PublicAPI(owner, recipient, anotherAccount);
  });

  describe('ERC20 internal API', function () {
    shouldBehaveLikeERC20InternalAPI(owner, recipient, anotherAccount);
  });
}

module.exports = {
  shouldBehaveLikeERC20,
};
