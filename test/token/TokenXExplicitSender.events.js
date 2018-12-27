const utils = require('./../utils.js');

module.exports = utils.makeEventMap({
  finalizeUpgrade: (contract, senderAddr) => [{
    eventName: 'UpgradeFinalized',
    paramMap: { c: contract,
                sender: senderAddr } }] });
