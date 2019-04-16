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

/* global assert */

const nodeAssert = require('assert');

const _assertReverts = async (f, reason = '', invertMatch = false) => {
  let res = false;
  nodeAssert(typeof (reason) === 'string');
  nodeAssert(typeof (invertMatch) === 'boolean');
  const specificReason = reason !== '';
  if (reason !== '') {
    reason = ' ' + reason;
  }
  const msgPrefix = 'VM Exception while processing transaction: revert';
  const expectedMsg = `${msgPrefix}${reason}`;
  try {
    await f;
  } catch (e) {
    const msg = e.message;
    if (msg.startsWith(msgPrefix)) {
      // testrpc-sc is required for coverage checking and does not include
      // revert reason in revert messages
      if (process.env.SOLIDITY_COVERAGE !== 'true') {
        if (specificReason && invertMatch) {
          assert(msg !== expectedMsg,
                 `Transaction reverted for the explicitly disallowed reason: ${msg}`);
        } else if (specificReason) {
          assert(msg === expectedMsg,
                 `Transaction reverted as expected, but for the wrong reason: ${msg}`);
        }
      }
      res = true;
    } else {
      assert(false,
             `Transaction failed, but it did not revert as expected: ${msg}`);
    }
  }
  assert(res, 'Transaction succeeded, but it was expected to fail');
};

exports.assertReverts = async (f) => {
  await _assertReverts(f);
};

// Asserts that the transaction reverts for a specific reason.
exports.assertRevertsReason = async (f, _reason) => {
  await _assertReverts(f, _reason);
};

// Asserts that the transaction reverts for any reason except the one provided.
exports.assertRevertsNotReason = async (f, reason) => {
  await _assertReverts(f, reason, true);
};

/**
   Assumes a hexadecimal number encoded as a string (starting with 0x)
   containing ASCII values.

   @returns A string of ASCII characters
*/
function bytes32ToString (str) {
  if (str.substring(0, 2) !== '0x') {
    throw new Error('Expected a string representation of a hex number starting with 0x');
  }
  let rest = str.substring(2, str.length);
  if ((rest.length % 2) !== 0) {
    throw new Error('Hex string must be of even length');
  }
  let parts = [];
  for (let i = 0; (i + 2) < rest.length; i += 2) {
    let part = parseInt('0x' + rest.substring(i, i + 2));
    // Use null termination
    if (part === 0 | 0) {
      break;
    }
    parts.push(part);
  }
  return parts.map((x) => String.fromCharCode(x)).join('');
}
exports.bytes32ToString = bytes32ToString;

function stringToBytes32 (str) {
  nodeAssert(typeof str === 'string');
  nodeAssert(str.length <= 32);
  const cs = str.split('');
  // Ensure that all chars in string are printable ASCII
  nodeAssert(cs.every(x => x.charCodeAt(0) >= 32 && x.charCodeAt(0) <= 126));
  return '0x'.concat(cs.map(x => x.charCodeAt(0).toString(16)).join('')).padEnd(66, '0');
}
exports.stringToBytes32 = stringToBytes32;

exports.ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
