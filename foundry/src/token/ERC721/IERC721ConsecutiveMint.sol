// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC721/IERC721.sol";

interface IERC721ConsecutiveMint is IERC721 {
    function totalSupply() external view returns (uint256);
    function exists(uint256 id) external view returns (bool);
}
