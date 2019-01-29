const events = require('./../../events.js');

module.exports = events.makeEventMap({
  changeMintingRecipient: (prevAddr, nextAddr) => [
    { eventName: 'MintingRecipientAccountChanged',
      paramMap: { prev: prevAddr,
                  next: nextAddr } }]
});
