const utils = require('./../../utils.js');

module.exports = utils.makeEventMap({
  latchInitialImplementor: (addr) => [{
    eventName: 'StorageInitialImplementorSet',
    paramMap: { to: addr } }],
  transferImplementor: (toAddr, fromAddr) => [{
    eventName: 'StorageImplementorTransferred',
    paramMap: { from: fromAddr,
                to: toAddr } }]
});
