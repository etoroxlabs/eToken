const events = require('./../events.js');

module.exports = events.makeEventMap({
  finalizeUpgrade: (contract) => [{
    eventName: 'UpgradeFinalized',
    paramMap: { upgradedFrom: contract } }],
  upgrade: (to, from) => [
    { eventName: 'UpgradeFinalized',
      paramMap: { upgradedFrom: from } },
    { eventName: 'Upgraded',
      paramMap: { to: to } } ]
});