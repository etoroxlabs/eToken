/* global web3 */

const BigNumber = web3.BigNumber;
require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

const truffleAssert = require('truffle-assertions');
const nodeAssert = require('assert');

const utils = require('./utils');

/**
   Given a transaction log and a list of expected events, ensure that the list
   contains a complete and in-order list of the events that were emitted during
   the transaction.

   The list of events should have the format [{eventName: string, paramMap:
   Object}], where eventName is the name of the event and paramMap lists event
   parameters and their expected events.
*/
let emittedEvents = (log, expectedEvents) => {
  nodeAssert(log !== undefined);
  nodeAssert(expectedEvents !== undefined);
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
    const v = typeof value === 'string' ? utils.stringToBytes32(value) : value;
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
        nodeAssert(fa !== undefined);
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
