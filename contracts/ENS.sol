pragma solidity ^0.4.23;

// Hack to get truffle to import ENS contracts
// See: https://github.com/trufflesuite/truffle/issues/450

import "@ensdomains/ens/contracts/ENSRegistry.sol";
import "@ensdomains/ens/contracts/PublicResolver.sol";
import "@ensdomains/ens/contracts/ReverseRegistrar.sol";
