/**
 * MIT License
 *
 * Copyright (c) 2019 eToroX Labs
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

const events = require('../../events.js');
const utils = require('../../utils.js');

module.exports = events.makeEventMap({
  // TODO: Implement the constructor using an inheritance system
  constructor: (addr) => [
    { eventName: 'OwnershipTransferred',
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
