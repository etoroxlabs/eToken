/* global assert, web3 */

const BigNumber = web3.BigNumber;
require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();
const truffleAssert = require('truffle-assertions');

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
  assert(typeof str === 'string');
  assert(str.length <= 32);
  const cs = str.split('');
  // Ensure that all chars in string are printable ASCII
  assert(cs.every(x => x.charCodeAt(0) >= 32 && x.charCodeAt(0) <= 126));
  return '0x'.concat(cs.map(x => x.charCodeAt(0).toString(16)).join('')).padEnd(66, '0');
}
exports.stringToBytes32 = stringToBytes32;

exports.ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

/**
   Given a transaction log and a list of expected events, ensure that the list
   contains a complete and in-order list of the events that were emitted during
   the transaction.

   The list of events should have the format [{eventName: string, paramMap:
   Object}], where eventName is the name of the event and paramMap lists event
   parameters and their expected events.
*/
let emittedEvents = (log, expectedEvents) => {
  assert(log !== undefined);
  assert(expectedEvents !== undefined);
  log.sort((a, b) => a.logIndex - a.logIndex);
  (log.length).should.be.equal(expectedEvents.length);
  for (let i = 0; i < log.length; i++) {
    const actual = log[i];
    const expected = expectedEvents[i];
    actual.event.should.be.equal(expected.eventName);
    (Object.entries(actual.args).length).should.be.equal(
      Object.entries(expected.paramMap).length);
    for (const [k, v] of Object.entries(expected.paramMap)) {
      contains(actual.args, k, v);
    }
  }
};
exports.emittedEvents = emittedEvents;

// Modified from Openzeppelin test library
function contains (args, key, value) {
  if (isBigNumber(args[key]) || isBigNumber(value)) {
    const v = typeof value === 'string' ? stringToBytes32(value) : value;
    args[key].should.be.bignumber.equal(v);
  } else {
    args[key].should.be.equal(value);
  }
}

// From openzeppelin test library
function isBigNumber (object) {
  return object.isBigNumber ||
    object instanceof BigNumber ||
    (object.constructor && object.constructor.name === 'BigNumber');
}

/**
   Like emittedEvents, but takes a contract creation instead of a log
*/
exports.emittedEventsContract = async (contract, expectedEvents) => {
  const { logs } =
        await truffleAssert.createTransactionResult(contract,
                                                    contract.transactionHash);
  emittedEvents(logs, expectedEvents);
};

function fromEntries (it) {
  let o = {};
  for (let [k, v] of it) {
      o[k] = v;
    }
  return o;
}

async function checkConstructorEvents (f, c, ...rest) {
  const { logs } = await truffleAssert.createTransactionResult(c, c.transactionHash);
  const e = f(...rest);
  emittedEvents(logs, e);
}

exports.makeEventMap = function (eventMap) {
  return { wrap: function (c) {
    return fromEntries(Object.entries(eventMap).map(([k, v]) => {
      if (!(k in c)) {
        throw Error(`Function ${k} not found in contract`);
      }
      if (k === 'constructor') {
        return [k, async function (...params) {
          await checkConstructorEvents(eventMap[k], ...params);
        }];
      } else {
        const fa = c.contract.abi.find(x => x.name === k);
        assert(fa !== undefined);
        const f = c[k];
        const fl = fa.inputs.length;
        const e = eventMap[k];
        const el = e.length;
        // TODO: Find a clever way to deal with type conversions between the
        // param map and the emitted events
        return [k,
                async function (...params) {
                  if ((params.length < el || params.length > (el + 1))) {
                    throw Error(
                      `Event wrapper for ${k} called with the wrong number of parameters`);
                  }
                  const lastPar = params.length > el ? 1 : 0;
                  const expectedEvents = e(...(params.slice(0, el)));
                  const pars = params.slice(0, fl)
                        .concat(lastPar ? [params[params.length - 1]] : []);
                  const res = await f(...pars);
                  const { logs } = res;
                  emittedEvents(logs, expectedEvents);
                }];
      }
    }));
  } };
};
