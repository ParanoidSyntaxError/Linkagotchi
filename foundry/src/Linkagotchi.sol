// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/utils/Base64.sol";
import "@openzeppelin/utils/Strings.sol";

import "@chainlink/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

import "./token/ERC6551/TokenBoundAccounts.sol";

contract Linkagotchi is TokenBoundAccounts, VRFConsumerBaseV2 {
    struct TokenData {
        uint256 lifeCycle;
        uint256 species;

        uint256 hunger;
        uint256 hungerTimestamp;

        uint256 sickness;
        uint256 sicknessBlockstamp;
    }

    address private immutable _vrfCoordinator;
    // VRF request ID => Token ID
    mapping(uint256 => uint256) internal _tokenIds;

    mapping(uint256 => TokenData) internal _tokenData;

    uint256 private constant _MAX_HUNGER = 108000;

    uint256 private constant _MAX_SICKNESS = 100;
    uint256 private constant _SICKNESS_RATE = 5000;
    uint256 private constant _SICKNESS_CHANCE = 10;
    uint256 private constant _SICKNESS_AMOUNT = 15;
    uint256 private constant _SICKNESS_HUNGER_MULTIPLIER = 2;
    uint256 private constant _SICKNESS_HUNGER_SCALE = 1000;

    uint256[] private _speciesLengths;

    constructor(
        address accountRegistry, 
        address accountImplementation, 
        uint256 accountChainId,
        address vrfCoordinator
    ) ERC721(
        "Linkgotchi", 
        "LINKGOTCHI"
    ) TokenBoundAccounts(
        accountRegistry, 
        accountImplementation, 
        accountChainId
    ) VRFConsumerBaseV2(
        vrfCoordinator
    ) {
        _vrfCoordinator = vrfCoordinator;

        _speciesLengths = [
            10
        ];
    }

    /**
        @notice Mint a new token
    
        @param receiver Address to receive the minted token

        @return requestId ID of the VRF request
        @return id ID of the minted token
        @return account Account bound to the minted token
    */
    function startMint(address receiver) external returns (uint256 requestId, uint256 id, address account) {      
        id = _nextTokenId();

        requestId = VRFCoordinatorV2Interface(_vrfCoordinator).requestRandomWords(
            "", //TODO
            0,  //TODO
            0,  //TODO
            0,  //TODO
            1
        );
        _tokenIds[requestId] = id;

        (,account) = _mintTokenAccount("", receiver);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        _newToken(_tokenIds[requestId], randomWords[0]);
    }

    function _newToken(uint256 id, uint256 random) internal {
        _tokenData[id].species = _randomSpecies(0, random);
        _tokenData[id].hungerTimestamp = block.timestamp;
        _tokenData[id].sicknessBlockstamp = block.number;
    }

    function _randomSpecies(uint256 lifeCycle, uint256 random) internal view returns (uint256) {
        return random % _speciesLengths[lifeCycle];
    }   

    function _grow(uint256 id, uint256 random) internal {
        _tokenData[id].lifeCycle++;
        _tokenData[id].species = _randomSpecies(_tokenData[id].lifeCycle, random);
    }

    function _feed(uint256 id, uint256 amount) internal {
        _tokenData[id].hunger = _safeSubtraction(_tokenData[id].hunger, amount);
    }

    function _medicine(uint256 id, uint256 amount) internal {
        _tokenData[id].sickness = _safeSubtraction(_tokenData[id].sickness, amount);
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

    function _safeSubtraction(uint256 a, uint256 b) internal pure returns (uint256) {
        if(b >= a) {
            return 0;
        }

        return a - b;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        _requireMinted(id);
         
        return string(abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(abi.encodePacked(
                '{"name":"Linkagotchi #',
                Strings.toString(id),
                '","description":"Germz are based","image":"',
                _tokenSvg(_tokenSvgHash(id)),
                '","attributes":',
                _tokenAttributes(id),
                '}'
            ))
        ));
    }

    function _tokenAttributes(uint256 id) internal view returns (string memory) {
        string memory attributes = string(abi.encodePacked(
            '{"trait_type":"Life cycle","value":"',
            Strings.toString(_tokenData[id].lifeCycle),
            '"},',
            '{"trait_type":"Species","value":"',
            Strings.toString(_tokenData[id].species),
            '"},',
            '{"trait_type":"Sickness","value":"',
            Strings.toString(_tokenData[id].sickness),
            '"},',
            '{"trait_type":"Hunger","value":"',
            Strings.toString(_tokenData[id].hunger),
            '"}'
        ));

        return string(abi.encodePacked("[", attributes, "]"));
    }

    function _tokenSvg(bytes memory svgHash) internal pure returns (string memory) {
        uint256 rectCount = (svgHash.length - 1) / 3;
        string memory rects;

        for(uint256 i; i < rectCount; i++) {
            uint256 bytesIndex = (i * 3) + 1;

            uint256 color = uint8(svgHash[bytesIndex]);
            (uint256 x, uint256 y) = _bytesToVector(svgHash[bytesIndex + 1]);
            (uint256 width, uint256 height) = _bytesToVector(svgHash[bytesIndex + 2]);

            rects = string(abi.encodePacked(
                rects, 
                "<rect class='w", 
                Strings.toString(color), 
                "' x='", 
                Strings.toString(x), 
                "' y='", 
                Strings.toString(y), 
                "' width='", 
                Strings.toString(width), 
                "' height='", 
                Strings.toString(height), 
                "'/>"
            ));
        }

        return string(abi.encodePacked(
            "<svg id='germz-svg' xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 16 16'><style>#germz-svg{shape-rendering: crispedges;}.w0{fill:#000000}.w1{fill:#FFFFFF}.w2{fill:#FF0000}.w3{fill:#00FF00}.w4{fill:#0000FF}.w5{fill:#00FFFF}.w6{fill:#FFFF00}.w7{fill:#FF00FF}</style>", 
            rects,
            "</svg>"
        ));
    }

    function _bytesToVector(bytes1 value) internal pure returns (uint256, uint256) {
        uint256 integer = uint8(value);
        return (integer % 16, integer / 16);
    }

    function _tokenSvgHash(uint256 id) internal view returns (bytes memory) {
        if(_tokenData[id].lifeCycle == 0) {
            if(_tokenData[id].species == 0) {
                return hex"00015612016446017321017A21006611008512007911";
            }
            if(_tokenData[id].species == 1) {
                
            }
            if(_tokenData[id].species == 2) {
                
            }
            if(_tokenData[id].species == 3) {
                
            }
            if(_tokenData[id].species == 4) {
                
            }
        }

        return "UNDEFINED";
    }
}