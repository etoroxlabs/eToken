/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() {
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>')
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */

require('@babel/polyfill');

const HDWalletProvider = require('truffle-hdwallet-provider');
const LedgerWalletProvider = require('truffle-ledger-provider');

const mnemonic = process.env.ETOKEN_MNEMONIC;
const ledgerOptions = {
  path: "44'/60'/0'/0/0",
  askConfirm: true,
  accountsLength: 1,
  accountsOffset: 0
};

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*',
      gas: 7000000
    },
    ropsten: {
      provider: function () {
        return new HDWalletProvider(mnemonic, 'https://ropsten.infura.io/');
      },
      gas: 8000000,
      gasPrice: 1000000,
      network_id: 3
    },
    mainnet: {
      provider: function () {
        return new LedgerWalletProvider(ledgerOptions, 'https://mainnet.infura.io/');
      },
      gas: 8000000,
      gasPrice: 60000000000,
      network_id: 1
    },
    coverage: {
      host: '127.0.0.1',
      network_id: '*',
      port: 8555, // <-- If you change this, also set the port option in .solcover.js.
      gas: 0xfffffffffff, // <-- Use this high gas value
      gasPrice: 0x01 // <-- Use this low gas price
    }
  },
  rpc: {
    host: 'localhost',
    post: '8080'
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      currency: 'USD',
      gasPrice: 20
    }
  }
};
