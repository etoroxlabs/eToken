# TokenX - an [eToro](https://www.etoro.com/) stablecoin
[![Build Status](https://circleci.com/gh/eTokenize/TokenX.svg?style=shield&circle-token=797dc9ae3f839ac4fc5d5edad6c993ae9faa3943&maxAge=0)](https://circleci.com/gh/eTokenize/TokenX) [![Coverage Status](https://coveralls.io/repos/github/eTokenize/TokenX/badge.svg?t=un8yQ7&maxAge=0)](https://coveralls.io/github/eTokenize/TokenX)

TokenX is stablecoin implementation by [eToro](https://www.etoro.com/) targeting the [Ethereum](https://www.ethereum.org/) platform.

## USAGE
To test the library and setup the development environment, issue the following commands in a shell:
```shell
  yarn install
  yarn test # compile and test
```

### Prerequisites
You need to have [`yarn`](https://yarnpkg.com/) and [`node`](https://nodejs.org/) installed.
This repository has only been tested on UNIX-derived systems.

## OVERVIEW
![overview](docs/images/contracts_overview.svg)

### TokenX - ERC20
#### External Storage

### Accesslist
#### Whitelist - KYC
#### Blacklist

### Token Manager

## FILES
Path | Description
------------- | -------------
`contracts/` | All the solidity files making up the implementation
`contracts/token` | Contains the TokenX implementation
`contracts/token/ERC20` | ERC20 implementation using an external storage
`contracts/roles` | Defines the roles implementation, i.e. whitelisting, blacklisting, miners etc.
`contracts/lifecycle` | Implements lifecycle behaviors. Taken from OpenZeppelin
`contracts/mocks` | Contracts used specifically for testing purposes
`test/`  | Contains testing code in JavaScript
`scripts/` | Specific scripts for testing, coverage & upgrading tokens

## LICENSE