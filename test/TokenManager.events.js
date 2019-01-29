const events = require('./events.js');
const utils = require('./utils.js');

module.exports = events.makeEventMap({
  constructor: () => [],
  addToken: (name, addr) => [{ eventName: 'TokenAdded',
                               paramMap: { name: utils.stringToBytes32(name),
                                           addr: addr } }],
  deleteToken: (name, addr) => [{ eventName: 'TokenDeleted',
                                  paramMap: {
                                    name: utils.stringToBytes32(name),
                                    addr: addr } }],
  upgradeToken: (name, newAddr, addr) =>
    [{ eventName: 'TokenUpgraded',
       paramMap: { name: utils.stringToBytes32(name),
                   from: addr,
                   to: newAddr } }]
});
