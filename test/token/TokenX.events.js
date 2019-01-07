const utils = require('./../utils.js');

module.exports = utils.makeEventMap({
  upgrade: (contract, oldContract) =>
    [{ eventName: 'UpgradeFinalized',
       paramMap: { c: oldContract,
                   sender: oldContract } },
    { eventName: 'Upgraded',
      paramMap: { to: contract } }] });
