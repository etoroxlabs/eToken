const utils = require('./../utils.js');

module.exports = utils.makeEventMap({
  finalizeUpgrade: (contract, senderAddr) => [{
    eventName: 'UpgradeFinalized',
    paramMap: { upgradedFrom: contract} }] });
