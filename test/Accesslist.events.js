const utils = require('./utils.js');

module.exports = utils.makeEventMap({
  // TODO: Implement the constructor using an inheritance system
  constructor: (addr) => [{ eventName: 'OwnershipTransferred',
                           paramMap: { previousOwner: utils.ZERO_ADDRESS,
                                       newOwner: addr } },
                          { eventName: 'WhitelistAdminAdded',
                           paramMap: { account: addr } },
                          { eventName: 'BlacklistAdminAdded',
                           paramMap: { account: addr } }
                         ],
  addWhitelisted: (addr) => [{ eventName: 'WhitelistAdded',
                               paramMap: { account: addr } }],
  removeWhitelisted: (addr) => [{ eventName: 'WhitelistRemoved',
                                  paramMap: { account: addr } }],
  addBlacklisted: (addr) => [{ eventName: 'BlacklistAdded',
                               paramMap: { account: addr } }],
  removeBlacklisted: (addr) => [{ eventName: 'BlacklistRemoved',
                                  paramMap: { account: addr } }]
});
