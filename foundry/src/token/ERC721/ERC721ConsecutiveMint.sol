// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC721/ERC721.sol";

import "./IERC721ConsecutiveMint.sol";

/**
    @dev Extension of the ERC721 standard that uses consecutive token ID's
*/
abstract contract ERC721ConsecutiveMint is IERC721ConsecutiveMint, ERC721 {
    uint256 private _totalSupply;

    /**
        @notice Return the token total supply

        @return totalSupply TODO
    */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
        @notice Return true if token ID has been minted

        @param id Token ID

        @return exists Token exists
    */
    function exists(uint256 id) external view returns (bool) {
        return _exists(id);
    }

    /**
        @dev Return the next token ID to be minted

        @return nextTokenId Next token ID minted
    */
    function _nextTokenId() internal view returns (uint256) {
        return _totalSupply;
    }

    /**
        @dev Mint token with a consecutive token ID

        @param receiver Token receiver

        @return id Token ID
    */
    function _consecutiveMint(address receiver) internal returns (uint256 id) {
        id = _nextTokenId();

        _totalSupply++;

        _safeMint(receiver, id);
    }
}