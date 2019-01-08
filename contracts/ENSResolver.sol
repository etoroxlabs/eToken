pragma solidity ^0.4.24;

import "./IENS.sol";

// modified from: http://docs.ens.domains/en/latest/implementers.html#resolving-names-onchain

contract ENSResolver {
    ENS ens;

    constructor(address ensAddress) public {
        ens = ENS(ensAddress);
    }

    function resolve(bytes32 node) view public returns(address) {
        Resolver resolver = ens.resolver(node);
        return resolver.addr(node);
    }
}
