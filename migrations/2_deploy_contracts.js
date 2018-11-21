var EToroToken = artifacts.require("./EToroToken.sol");
var EtoroRole = artifacts.require("./EToroRole.sol")

module.exports = function(deployer) {
   
  deployer.deploy(EtoroRole).then((rolesContract) =>
      deployer.deploy(EToroToken, "EToro USD", "ETUSD", 18, rolesContract.address)
  );
};
