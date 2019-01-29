const utils = require('./../utils.js');

module.exports = utils.makeEventMap({
  finalizeUpgrade: (contract) => [{
    eventName: 'UpgradeFinalized',
    paramMap: { upgradedFrom: contract} }] });
