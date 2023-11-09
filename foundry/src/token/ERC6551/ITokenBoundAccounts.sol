// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../ERC721/IERC721ConsecutiveMint.sol";

interface ITokenBoundAccounts is IERC721ConsecutiveMint {
    function isAccount(address account) external view returns (bool);
    function tokenId(address account) external view returns (uint256);
    function tokenAccount(uint256 id) external view returns (address);
}
