// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./token/ERC6551/TokenBoundAccounts.sol";

contract Linkgotchi is TokenBoundAccounts {
    struct TokenData {
        uint256 lifeCycle;
        uint256 species;

        uint256 hunger;
        uint256 hungerTimestamp;

        uint256 sickness;
        uint256 sicknessBlockstamp;
    } 

    mapping(uint256 => TokenData) internal _tokenData;

    uint256 private constant _MAX_HUNGER = 108000;

    uint256 private constant _MAX_SICKNESS = 100;
    uint256 private constant _SICKNESS_RATE = 5000;
    uint256 private constant _SICKNESS_CHANCE = 10;
    uint256 private constant _SICKNESS_AMOUNT = 15;
    uint256 private constant _SICKNESS_HUNGER_MULTIPLIER = 2;
    uint256 private constant _SICKNESS_HUNGER_SCALE = 1000;

    constructor(
        address accountRegistry, 
        address accountImplementation, 
        uint256 accountChainId
    ) ERC721(
        "Linkgotchi", 
        "LINKGOTCHI"
    ) TokenBoundAccounts(
        accountRegistry, 
        accountImplementation, 
        accountChainId
    ) {}

    /**
        @notice Mint a new token
    
        @param receiver Address to receive the minted token

        @return id ID of the minted token
        @return account Account bound to the minted token
    */
    function mint(address receiver) external returns (uint256 id, address account) {      
        id = _nextTokenId();

        // TODO: Seed
        _newToken(id, 0);

        (,account) = _mintTokenAccount("", receiver);
    }

    function _newToken(uint256 id, uint256 seed) internal {
        _tokenData[id] = TokenData(
            0, 
            777, //TODO: Random species
            0, 
            block.timestamp,
            0,
            block.number
        );
    }
    
    function _grow(uint256 id) internal {
        _tokenData[id].lifeCycle++;
    }

    function _feed(uint256 id, uint256 amount) internal {
        if(amount >= _tokenData[id].hunger) {
            _tokenData[id].hunger = 0;
            return;
        }

        _tokenData[id].hunger -= amount;
    }

    function _medicine(uint256 id, uint256 amount) internal {
        if(amount >= _tokenData[id].sickness) {
            _tokenData[id].sickness = 0;
            return;
        }

        _tokenData[id].sickness -= amount;
    }

    function _hunger(uint256 id) internal view returns (uint256) {
        return _tokenData[id].hunger + (block.timestamp - _tokenData[id].hungerTimestamp);
    }

    function _sickness(uint256 id) internal view returns (uint256 sickness) {
        sickness = _tokenData[id].sickness;
        uint256 checks = (block.number - _tokenData[id].sicknessBlockstamp) / _SICKNESS_RATE;

        for(uint256 i; i < checks; i++) {
            uint256 random = uint256(blockhash(_tokenData[id].sicknessBlockstamp + (i * _SICKNESS_RATE)));

            if(random % _SICKNESS_CHANCE == 0 || sickness > 0) {
                uint256 hungerMultiplier = ((_hunger(id) * _SICKNESS_HUNGER_SCALE) / _MAX_HUNGER) * _SICKNESS_HUNGER_MULTIPLIER;
                sickness += ((_SICKNESS_AMOUNT * hungerMultiplier) / _SICKNESS_HUNGER_SCALE) + _SICKNESS_AMOUNT;
            }
        }
    }

    function _isAlive(uint256 id) internal view returns (bool) {
        if(_hunger(id) >= _MAX_HUNGER || _sickness(id) >= _MAX_SICKNESS) {
            return false;
        } 

        return true;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "";
    }
}