pragma solidity ^0.4.24;

library bytes32utils {
    function strLen(bytes32 self) pure returns (uint256) {
        uint256 len;
        for (; len < 32; len++) {
            if (self[len] == 0) {
                break;
            }
        }
        return len;
    }

    function endsWith(bytes32 self, bytes32 str) pure returns (bool) {
        uint256 lenA = strLen(self);
        uint256 lenB = strLen(str);
        require(lenB <= lenA, "bytes32 tail must be shorter than str");

        bool res = true;
        while (lenB > 0) {
            if (self[lenB] != self[lenA]) {
                res = false;
            }
            lenA--;
            lenB--;
        }
        return res;
    }
}
