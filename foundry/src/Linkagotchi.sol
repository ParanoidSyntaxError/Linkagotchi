// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Base64} from "@openzeppelin/utils/Base64.sol";
import {Strings} from "@openzeppelin/utils/Strings.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";

import {VRFConsumerBaseV2} from "@chainlink/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

import {ERC721ConsecutiveMint} from "./token/ERC721/ERC721ConsecutiveMint.sol";

import {ILinkagotchi} from "./ILinkagotchi.sol";

contract Linkagotchi is ILinkagotchi, ERC721ConsecutiveMint, VRFConsumerBaseV2 {
    struct TokenData {
        uint256 lifeCycle;
        uint256 species;

        uint256 hunger;
        uint256 hungerTimestamp;

        uint256 sickness;
        uint256 sicknessBlockstamp;
    }

    address private immutable _linkToken;

    address private immutable _vrfCoordinator;
    // VRF request ID => Token ID
    mapping(uint256 => uint256) private _vrfTokenIds;

    mapping(uint256 => TokenData) private _tokens;

    uint256 public immutable blockMultiplier;

    uint256 public constant FEED_FEE = 1;
    uint256 public constant MEDICINE_FEE = 1;

    uint256 private constant _MAX_HUNGER = 108000;

    uint256 private constant _MAX_SICKNESS = 100;
    uint256 private _sicknessRate = 2500;
    uint256 private constant _SICKNESS_CHANCE = 10;
    uint256 private constant _SICKNESS_AMOUNT = 15;
    uint256 private constant _SICKNESS_HUNGER_MULTIPLIER = 2;
    uint256 private constant _SICKNESS_HUNGER_SCALE = 1000;

    uint256[] private _speciesLengths;

    constructor(
        uint256 blockMulti,
        address linkToken,
        address vrfCoordinator
    ) ERC721(
        "Linkgotchi", 
        "LINKGOTCHI"
    ) VRFConsumerBaseV2(
        vrfCoordinator
    ) {
        blockMultiplier = blockMulti;

        _sicknessRate *= blockMultiplier;

        _linkToken = linkToken;
        _vrfCoordinator = vrfCoordinator;

        _speciesLengths = [
            5
        ];
    }

    function debugMint(address receiver) external returns (uint256 requestId, uint256 id) {    
        id = _nextTokenId();
        requestId = id;

        _vrfTokenIds[id] = id;

        _consecutiveMint(receiver);
    }

    function debugFulfillRandomWords(uint256 requestId, uint256 randomWords) external {
        _newToken(_vrfTokenIds[requestId], randomWords);
    }

    /**
        @notice Mint a new token
    
        @param receiver Address to receive the minted token

        @return requestId ID of the VRF request
        @return id ID of the minted token
    */
    function mint(address receiver) external override returns (uint256 requestId, uint256 id) {      
        id = _nextTokenId();

        requestId = VRFCoordinatorV2Interface(_vrfCoordinator).requestRandomWords(
            "", //TODO
            0,  //TODO
            0,  //TODO
            0,  //TODO
            1
        );
        _vrfTokenIds[requestId] = id;

        _consecutiveMint(receiver);
    }

    /**
        @notice Feed a Linkagotchi
    
        @param id Token ID
        @param amount Amount hunger is decreased by
    */
    function feed(uint256 id, uint256 amount) external override {
        _requireMinted(id);
        require(_sickness(id) == 0);

        IERC20(_linkToken).transferFrom(msg.sender, address(this), amount * FEED_FEE);

        _feed(id, amount);
    }

    /**
        @notice Cure a Linkagotchi
    
        @param id Token ID
        @param amount Amount sickness is decreased by
    */
    function medicine(uint256 id, uint256 amount) external override {
        _requireMinted(id);

        IERC20(_linkToken).transferFrom(msg.sender, address(this), amount * MEDICINE_FEE);

        _medicine(id, amount);
    }

    /**
        @notice Get a Linkagotchi's stats
    
        @param id Token ID

        @return lifeCycle Life cycle ID
        @return species Species ID
        @return hunger Hunger level
        @return sickness Sickness level
        @return alive Is the Linkagotchi alive
    */
    function stats(uint256 id) external view override returns (uint256, uint256, uint256, uint256, bool) {
        return (_tokens[id].lifeCycle, _tokens[id].species, _hunger(id), _sickness(id), _isAlive(id));
    }

    /**
        @dev See {IERC721Metadata-tokenURI}.
    */
    function tokenURI(uint256 id) public view override returns (string memory) {
        _requireMinted(id);
         
        return string(abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(abi.encodePacked(
                '{"name":"Linkagotchi #',
                Strings.toString(id),
                '","description":"Take care of your Linkagotchi anon!","image":"data:image/svg+xml;base64,',
                Base64.encode(bytes(_tokenSvg(_tokenSvgHash(id)))),
                '","attributes":',
                _tokenAttributes(id),
                '}'
            ))
        ));
    }

    /**
        @dev See {VRFConsumerBaseV2-fulfillRandomWords}.
    */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        _newToken(_vrfTokenIds[requestId], randomWords[0]);
    }

    function _newToken(uint256 id, uint256 random) internal {
        _tokens[id].species = _randomSpecies(0, random);
        _tokens[id].hungerTimestamp = block.timestamp;
        _tokens[id].sicknessBlockstamp = block.number;
    }

    function _setToken(uint256 id, TokenData memory tokenData) internal {
        _tokens[id] = tokenData;
    }

    function _grow(uint256 id, uint256 random) internal {
        _tokens[id].lifeCycle++;
        _tokens[id].species = _randomSpecies(_tokens[id].lifeCycle, random);
    }

    function _feed(uint256 id, uint256 amount) internal {
        _tokens[id].hunger = _safeSubtraction(_tokens[id].hunger, amount);
    }

    function _medicine(uint256 id, uint256 amount) internal {
        _tokens[id].sickness = _safeSubtraction(_tokens[id].sickness, amount);
    }

    function _token(uint256 id) internal view returns (TokenData memory tokenData) {
        return _tokens[id];
    }

    function _randomSpecies(uint256 lifeCycle, uint256 random) internal view returns (uint256) {
        return random % _speciesLengths[lifeCycle];
    }   

    function _hunger(uint256 id) internal view returns (uint256) {
        return _tokens[id].hunger + (block.timestamp - _tokens[id].hungerTimestamp);
    }

    function _sickness(uint256 id) internal view returns (uint256 sickness) {
        sickness = _tokens[id].sickness;
        uint256 checks = (block.number - _tokens[id].sicknessBlockstamp) / _sicknessRate;

        for(uint256 i; i < checks; i++) {
            uint256 random = _blockhashRandom(id, _tokens[id].sicknessBlockstamp + (i * _sicknessRate));

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
            "<svg id='linkagotchi-svg' xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 16 16'><style>#linkagotchi-svg{shape-rendering: crispedges;}.w0{fill:#000000}.w1{fill:#FFFFFF}.w2{fill:#FF0000}.w3{fill:#00FF00}.w4{fill:#0000FF}.w5{fill:#00FFFF}.w6{fill:#FFFF00}.w7{fill:#FF00FF}</style>", 
            "<rect class='w0' x='0' y='0' width='16' height='16'/>",
            rects,
            "</svg>"
        ));
    }

    function _tokenSvgHash(uint256 id) internal view returns (bytes memory) {
        if(_tokens[id].lifeCycle == 0) {
            if(_tokens[id].species == 0) {
                return hex"00015612016446017321017A21006611008512007911";
            }
            if(_tokens[id].species == 1) {
                return hex"00015712016614017546018B21018421006711007911009612";
            }
            if(_tokens[id].species == 2) {
                return hex"0001561301651501743701A515007611007911009612";
            }
            if(_tokens[id].species == 3) {
                return hex"00015811016713017645018B21018521007911008611009812";
            }
            if(_tokens[id].species == 4) {
                return hex"0001671301764501B713018B2101852100771100891100A712";
            }
        } else if(_tokens[id].species == 1) {
            if(_tokens[id].species == 0) {
            }
            if(_tokens[id].species == 1) {
            }
            if(_tokens[id].species == 2) {
            }
            if(_tokens[id].species == 3) {
            }
            if(_tokens[id].species == 4) {
            }
        }

        return "UNDEFINED";
    }
    
    function _tokenAttributes(uint256 id) internal view returns (string memory) {
        string memory attributes = string(abi.encodePacked(
            '{"trait_type":"Life cycle","value":"',
            Strings.toString(_tokens[id].lifeCycle),
            '"},',
            '{"trait_type":"Species","value":"',
            Strings.toString(_tokens[id].species),
            '"},',
            '{"trait_type":"Sickness","value":"',
            Strings.toString(_tokens[id].sickness),
            '"},',
            '{"trait_type":"Hunger","value":"',
            Strings.toString(_tokens[id].hunger),
            '"}'
        ));

        return string(abi.encodePacked("[", attributes, "]"));
    }

    function _blockhashRandom(uint256 id, uint256 blockNumber) internal view returns (uint256) {
        unchecked {
            return uint256(blockhash(blockNumber)) * id;   
        }
    }

    function _bytesToVector(bytes1 value) internal pure returns (uint256, uint256) {
        uint256 integer = uint8(value);

        return (integer % 16, integer / 16);
    }

    function _safeSubtraction(uint256 a, uint256 b) internal pure returns (uint256) {
        if(b >= a) {
            return 0;
        }

        return a - b;
    }
}