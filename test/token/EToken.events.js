const events = require('./../events.js');

module.exports = events.makeEventMap({
  upgrade: (contract, oldContract) => [
    { eventName: 'UpgradeFinalized',
      paramMap: { upgradedFrom: oldContract } },
    { eventName: 'Upgraded',
      paramMap: { to: contract } }] });
