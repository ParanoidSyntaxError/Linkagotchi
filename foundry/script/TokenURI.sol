// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Helper.sol";

contract TokenURI is Helper {
    function run() public {
        address tokenReceiver = newAddress();

        (uint256 id, uint256 requestId) = linkagotchi.debugMint(tokenReceiver);
        linkagotchi.debugFulfillRandomWords(requestId, 12);

        console.log(linkagotchi.tokenURI(id));
    }
}