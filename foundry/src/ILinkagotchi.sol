// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILinkagotchi {
    function mint(address receiver) external returns (uint256 requestId, uint256 id, address account);

    function feed(uint256 id, uint256 amount) external;
    function medicine(uint256 id, uint256 amount) external;

    function stats(uint256 id) external view returns (uint256 lifeCycle, uint256 species, uint256 hunger, uint256 sickness, bool alive);
}