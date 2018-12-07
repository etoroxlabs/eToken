const BigNumber = web3.BigNumber;
const should = require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();
const truffleAssert = require("truffle-assertions");

exports.assertReverts = async (f) => {
    let res = false;
    try {
        await f;
    } catch (e) {
        assert(e.message === 'VM Exception while processing transaction: revert',
               "Got an error as expected, but it was of the wrong kind");
        res = true;
    }
    assert(res, "Expected an error");
}

const tokName = "eUSD";

/**
   Assumes a hexadecimal number encoded as a string (starting with 0x)
   containing ASCII values.

   @returns A string of ASCII characters
*/
exports.bytes32ToString = (str) => {
    if (str.substring(0, 2) !== "0x") {
        throw new Error("Expected a string representation of a hex number starting with 0x");
    }
    let rest = str.substring(2, str.length);
    if ((rest.length % 2) !== 0) {
        throw new Error("Hex string must be of even length");
    }
    let parts = [];
    for (let i = 0; (i + 2) < rest.length; i += 2) {
        let part = parseInt("0x" + rest.substring(i, i + 2));
        // Use null termination
        if (part === 0|0) {
            break;
        }
        parts.push(part);
    }
    return  parts.map((x) => String.fromCharCode(x)).join('');
}

/**
   Given a transaction log and a list of expected events, ensure that the list
   contains a complete and in-order list of the events that were emitted during
   the transaction.

   The list of events should have the format [{eventName: string, paramMap:
   Object}], where eventName is the name of the event and paramMap lists event
   parameters and their expected events.
*/
let emittedEvents = (log, expectedEvents) => {
    log.sort((a, b) => {a.logIndex - a.logIndex});
    (log.length).should.be.equal(expectedEvents.length);
    for (let i = 0; i < log.length; i++) {
        const event = log[i];
        const expect = expectedEvents[i];
        event.event.should.be.equal(expect.eventName);
        (Object.entries(event.args).length).should.be.equal(
            Object.entries(expect.paramMap).length);
         for (const [k, v] of Object.entries(expect.paramMap)) {
             contains(event.args, k, v);
         }
    }
}
exports.emittedEvents = emittedEvents;

/**
   Like emittedEvents, but takes a contract creation instead of a log
*/
exports.emittedEventsContract = async (contract, expectedEvents) => {
    const { logs } =
          await truffleAssert.createTransactionResult(contract,
                                                      contract.transactionHash);
    emittedEvents(logs, expectedEvents);
}


// From Openzeppelin test library
function contains (args, key, value) {
  if (isBigNumber(args[key])) {
    args[key].should.be.bignumber.equal(value);
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
