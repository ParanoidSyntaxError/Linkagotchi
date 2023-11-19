// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Env.sol";

contract Helper is Env {
    uint256 private _addrNonce;

    function newAddress() public returns (address) {
        _addrNonce++;
        return vm.addr(_addrNonce);
    }
}