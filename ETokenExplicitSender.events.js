const events = require('./../events.js');

module.exports = events.makeEventMap({
  finalizeUpgrade: (contract) => [{
    eventName: 'UpgradeFinalized',
    paramMap: { upgradedFrom: contract } }] });
