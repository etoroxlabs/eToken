const utils = require('./../../utils.js');

module.exports = utils.makeEventMap({
  transferImplementor: (toAddr, fromAddr) => [{
    eventName: 'StorageImplementorTransferred',
    paramMap: { from: fromAddr,
                to: toAddr } }]
});
