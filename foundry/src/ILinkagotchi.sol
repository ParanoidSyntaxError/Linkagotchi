// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ILinkagotchi {
    function blockMultiplier() external view returns (uint256);

    function mintCost() external pure returns (uint256);
    function feedCost() external pure returns (uint256);
    function healCost() external pure returns (uint256);

    function stats(uint256 id) external view returns (uint256 lifeCycle, uint256 species, uint256 hunger, uint256 sickness, bool alive);

    function mint(address receiver, uint256 vrfFee, uint32 callbackGasLimit) external returns (uint256 requestId, uint256 id);

    function feed(uint256 id, uint256 amount) external;
    function heal(uint256 id, uint256 amount) external;
}