// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

import {ILinkie} from "./ILinkie.sol";

interface ERC677Receiver {
    function onTokenTransfer(address sender, uint256 value, bytes memory data) external;
}

contract LinkieHelper is ERC677Receiver {
    address public immutable linkie;
    address public immutable linkToken;

    constructor(address linkieContract, address linkTokenContract) {
        linkie = linkieContract;
        linkToken = linkTokenContract;

        IERC20(linkTokenContract).approve(linkieContract, type(uint256).max);
    }

    function onTokenTransfer(address sender, uint256 value, bytes memory data) external override {
        require(msg.sender == linkToken);

        (uint256 callType, bytes memory callData) = abi.decode(data, (uint256, bytes));

        if(callType == 0) {
            // Mint
            (bytes32 keyHash, uint32 callbackGasLimit) = abi.decode(callData, (bytes32, uint32));

            uint256 mintCost = ILinkie(linkie).mintCost();
            
            ILinkie(linkie).mint(sender, value - mintCost, keyHash, callbackGasLimit);
        } else if(callType == 1) {
            // Feed
            (uint256 id) = abi.decode(callData, (uint256));

            uint256 amount = value / ILinkie(linkie).feedCost();

            ILinkie(linkie).feed(id, amount);
        } else if(callType == 2) {
            // Heal
            (uint256 id) = abi.decode(callData, (uint256));

            uint256 amount = value / ILinkie(linkie).healCost();

            ILinkie(linkie).heal(id, amount);
        }
    }
}