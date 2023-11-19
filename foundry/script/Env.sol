// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "../src/Linkie.sol";

contract Env is Test {
    Linkie public linkie;

    function setUp() public {
        linkie = new Linkie(1000, address(0), address(0));
    }
}