// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../src/Linkagotchi.sol";

contract Env is Test {
    Linkagotchi public linkagotchi;

    function setUp() public {
        linkagotchi = new Linkagotchi(address(0), address(0), 0, address(0), address(0));
    }
}