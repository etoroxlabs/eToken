/* global assert */

const _assertReverts = async (f, reason = '', invertMatch = false) => {
  let res = false;
  assert(typeof (reason) === 'string');
  assert(typeof (invertMatch) === 'boolean');
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
exports.bytes32ToString = (str) => {
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
};

exports.ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
