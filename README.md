# eToken - an [eToro](https://www.etoro.com/) stablecoin
[![Build Status](https://circleci.com/gh/etoroxlabs/eToken.svg?style=shield&circle-token=797dc9ae3f839ac4fc5d5edad6c993ae9faa3943&maxAge=0)](https://circleci.com/gh/etoroxlabs/eToken) [![Coverage Status](https://coveralls.io/repos/github/etoroxlabs/eToken/badge.svg?maxAge=0)](https://coveralls.io/github/etoroxlabs/eToken)

eToken is stablecoin implementation by [eToro](https://www.etoro.com/) targeting the [Ethereum](https://www.ethereum.org/) platform.

## USAGE
To test the library and setup the development environment, issue the following commands in a shell:
```shell
  yarn install
  yarn test # compile and test
```

### Prerequisites
You need to have [`yarn`](https://yarnpkg.com/) and [`node`](https://nodejs.org/) installed.
This repository has only been tested on UNIX-derived systems.

## Design overview
See [separate document](docs/design_overview.md).

## FILES
Path | Description
------------- | -------------
`contracts/` | All the solidity files making up the implementation
`contracts/token` | Contains the eToken implementation
`contracts/token/ERC20` | ERC20 implementation using an external storage
`contracts/roles` | Defines the roles implementation, i.e. whitelisting, blacklisting, miners etc.
`contracts/lifecycle` | Implements lifecycle behaviors. Taken from OpenZeppelin
`contracts/mocks` | Contracts used specifically for testing purposes
`test/`  | Contains testing code in JavaScript
`scripts/` | Specific scripts for testing, coverage & upgrading tokens
