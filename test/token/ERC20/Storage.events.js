const events = require('./../../events.js');

module.exports = events.makeEventMap({
  transferImplementor: (toAddr, fromAddr) => [{
    eventName: 'StorageImplementorTransferred',
    paramMap: { from: fromAddr,
                to: toAddr } }]
});
