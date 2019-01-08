pragma solidity ^0.4.24;

// modified from: http://docs.ens.domains/en/latest/implementers.html#resolving-names-onchain

contract ENS {
    function owner(bytes32 node) view external returns (address);
    function resolver(bytes32 node) view external returns (Resolver);
    function ttl(bytes32 node) view external returns (uint64);
    function setOwner(bytes32 node, address _owner) external;
    function setSubnodeOwner(bytes32 node, bytes32 label, address _owner) external;
    function setResolver(bytes32 node, address _resolver) external;
    function setTTL(bytes32 node, uint64 _ttl) external;
}

contract Resolver {
    function addr(bytes32 node) view external returns (address);
}
