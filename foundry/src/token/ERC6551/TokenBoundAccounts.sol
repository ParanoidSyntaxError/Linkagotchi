// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../ERC721/ERC721ConsecutiveMint.sol";

import "@erc6551/interfaces/IERC6551Registry.sol";
import "./ITokenBoundAccounts.sol";

/**
    @dev Extension of ERC721ConsecutiveMint that binds accounts to tokens https://eips.ethereum.org/EIPS/eip-6551
*/
abstract contract TokenBoundAccounts is ITokenBoundAccounts, ERC721ConsecutiveMint {
    // Token account => Token ID + 1
    // By adding one to the token ID you can easily identify addresses that are token accounts without an extra mapping of bools
    mapping(address => uint256) private _ids;
    // Token ID => Token account
    mapping(uint256 => address) private _accounts;

    address public immutable registry;
    address public immutable implementation;
    uint256 public immutable chainId;

    /**
        @dev Initialize contracts token bound account values

        @param accountRegistry EIP-6551 account registry
        @param accountImplementation EIP-6551 account implementation
        @param accountChainId The EIP-155 ID of the chain the token exists on
    */
    constructor(
        address accountRegistry, 
        address accountImplementation, 
        uint256 accountChainId
    ) {              
        registry = accountRegistry;
        implementation = accountImplementation;
        chainId = accountChainId;
    }

    /**
        @notice Return true if address is token account

        @param account Token account

        @return isAccount Is address token account
    */
    function isAccount(address account) external view override returns (bool) {
        return _isAccount(account);
    }

    /**
        @notice Return token ID

        @param account Token account

        @return id Token ID
    */
    function tokenId(address account) external view override returns (uint256) {
        require(_isAccount(account));
        
        return _tokenId(account);
    }

    /**
        @notice Return token account

        @param id Token ID

        @return account Token account
    */
    function tokenAccount(uint256 id) external view override returns (address) {
        _requireMinted(id);
        
        return _accounts[id];
    }

    /**
        @dev Mint token with a bound account

        @param salt Address creation salt
        @param receiver Token receiver

        @return id Token ID
        @return account Token account
    */
    function _mintTokenAccount(bytes32 salt, address receiver) internal returns (uint256 id, address account) {
        id = _nextTokenId();

        account = IERC6551Registry(registry).createAccount(implementation, salt, chainId, address(this), id);
        _accounts[id] = account;
        _ids[account] = id + 1;

        _consecutiveMint(receiver);
    }

    /**
        @dev Return true if address is a token account

        @param account Token account

        @return isAccount Is address token account
    */
    function _isAccount(address account) internal view returns (bool) {
        return _ids[account] > 0;
    }

    /**
        @dev Return token ID

        @param account Token account

        @return id Token ID
    */
    function _tokenId(address account) internal view returns (uint256) {
        return _ids[account] - 1;
    }
}