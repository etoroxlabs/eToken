const utils = require('./../..//utils.js');

module.exports = utils.makeEventMap({
  changeMintingRecipient: (prevAddr, nextAddr) => [
    { eventName: 'MintingRecipientAccountChanged',
      paramMap: { prev: prevAddr,
                  next: nextAddr } }]
});
