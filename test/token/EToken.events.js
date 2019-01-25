const utils = require('./../utils.js');

module.exports = utils.makeEventMap({
  upgrade: (contract, oldContract) => [
    { eventName: 'UpgradeFinalized',
      paramMap: { upgradedFrom: oldContract} },
    { eventName: 'Upgraded',
      paramMap: { to: contract } }] });
