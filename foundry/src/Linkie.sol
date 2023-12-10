// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Base64} from "@openzeppelin/utils/Base64.sol";
import {Strings} from "@openzeppelin/utils/Strings.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ERC721Enumerable, ERC721} from "@openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";

import {VRFConsumerBaseV2} from "@chainlink/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {LinkTokenInterface} from "@chainlink/shared/interfaces/LinkTokenInterface.sol";

import {ILinkie} from "./ILinkie.sol";

contract Linkie is ILinkie, ERC721Enumerable, VRFConsumerBaseV2, Ownable {
    struct TokenData {
        uint256 lifeCycle;
        uint256 lifeCycleBlockstamp;
        uint256 species;

        uint256 hunger;
        uint256 hungerTimestamp;

        uint256 sickness;
        uint256 sicknessBlockstamp;
    }

    address public immutable linkToken;

    address public immutable vrfCoordinator;
    uint64 public immutable subscriptionId;

    // VRF request ID => Token ID
    mapping(uint256 => uint256) private _vrfTokenIds;

    mapping(uint256 => TokenData) private _tokens;

    uint256 private constant _MINT_COST = 0.1 ether;

    uint256 private immutable _blockMultiplier;

    uint256 private constant _FEED_COST = 1;
    uint256 private constant _HEAL_COST = 1;

    uint256 private _growthRate = 50; // Number of blocks between growths multiplied by blockMultiplier

    uint256 private constant _MAX_HUNGER = 108000;

    uint256 private constant _MAX_SICKNESS = 100;
    uint256 private _sicknessRate = 5; // Number of blocks between sickness rolls multiplied by blockMultiplier
    uint256 private constant _SICKNESS_CHANCE = 10;
    uint256 private constant _SICKNESS_AMOUNT = 15;
    uint256 private constant _SICKNESS_HUNGER_MULTIPLIER = 2;
    uint256 private constant _SICKNESS_HUNGER_SCALE = 1000;

    uint256[] private _speciesLengths;

    constructor(
        uint256 blockMulti,
        address link,
        address vrf
    ) ERC721(
        "Linkie", 
        "LINKIE"
    ) VRFConsumerBaseV2(
        vrf
    ) {
        _blockMultiplier = blockMulti;
        _sicknessRate *= blockMulti;
        _growthRate *= blockMulti;

        linkToken = link;

        _speciesLengths = [
            1, // Baby
            2, // Child
            2, // Teen
            2  // Adult
        ];

        vrfCoordinator = vrf;
        subscriptionId = VRFCoordinatorV2Interface(vrfCoordinator).createSubscription();
        VRFCoordinatorV2Interface(vrfCoordinator).addConsumer(subscriptionId, address(this));
    }

    /**
        @notice DEBUG FUNCTION. NOT FOR PRODUCTION
    */
    function setToken(
        uint256 id,
        uint256 lifeCycle, 
        uint256 lifeCycleBlockstamp, 
        uint256 species, 
        uint256 hunger, 
        uint256 hungerTimestamp, 
        uint256 sickness, 
        uint256 sicknessBlockstamp
    ) external onlyOwner() {
        _tokens[id] = TokenData(
            lifeCycle, 
            lifeCycleBlockstamp, 
            species, 
            hunger, 
            hungerTimestamp,
            sickness,
            sicknessBlockstamp
        );
    }

    function blockMultiplier() external view override returns (uint256) {
        return _blockMultiplier;
    }

    function mintCost() external pure override returns (uint256) {
        return _MINT_COST;
    }

    function feedCost() external pure override returns (uint256) {
        return _FEED_COST;
    }

    function healCost() external pure override returns (uint256) {
        return _HEAL_COST;
    }

    /**
        @notice Get a Linkies stats
    
        @param id Token ID

        @return lifeCycle Life cycle ID
        @return species Species ID
        @return hunger Hunger level
        @return sickness Sickness level
        @return alive Is the Linkie alive
    */
    function stats(uint256 id) external view override returns (uint256, uint256, uint256, uint256, bool) {
        return (_lifeCycle(id), _species(id), _hunger(id), _sickness(id), _isAlive(id));
    }

    /**
        @notice Mint a new token
    
        @param receiver Address to receive the minted token
        @param vrfFee Amount of LINK tokens to pay the VRF coordinator
        @param callbackGasLimit Limit of how much gas to use for the callback

        @return requestId ID of the VRF request
        @return id ID of the minted token
    */
    function mint(address receiver, uint256 vrfFee, bytes32 keyHash, uint32 callbackGasLimit) public virtual override returns (uint256 requestId, uint256 id) {      
        IERC20(linkToken).transferFrom(msg.sender, address(this), _MINT_COST + vrfFee);
        
        id = totalSupply();

        LinkTokenInterface(linkToken).transferAndCall(vrfCoordinator, vrfFee, abi.encode(subscriptionId));
        requestId = VRFCoordinatorV2Interface(vrfCoordinator).requestRandomWords(
            keyHash, 
            subscriptionId, 
            5, 
            callbackGasLimit, 
            1
        );
        _vrfTokenIds[requestId] = id;

        _safeMint(receiver, id);
    }

    /**
        @dev See {VRFConsumerBaseV2-fulfillRandomWords}.
    */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        _newToken(_vrfTokenIds[requestId], randomWords[0]);
    }

    /**
        @notice Feed a Linkie
    
        @param id Token ID
        @param amount Amount hunger is decreased by
    */
    function feed(uint256 id, uint256 amount) external override {
        _requireMinted(id);
        require(_isAlive(id));
        require(_sickness(id) == 0);

        IERC20(linkToken).transferFrom(msg.sender, address(this), amount * _FEED_COST);

        _feed(id, amount);

        _checkGrowth(id);
    }

    /**
        @notice Cure a Linkie
    
        @param id Token ID
        @param amount Amount sickness is decreased by
    */
    function heal(uint256 id, uint256 amount) external override {
        _requireMinted(id);
        require(_isAlive(id));

        IERC20(linkToken).transferFrom(msg.sender, address(this), amount * _HEAL_COST);

        _heal(id, amount);

        _checkGrowth(id);
    }

    /**
        @dev See {IERC721Metadata-tokenURI}.
    */
    function tokenURI(uint256 id) public view override returns (string memory) {
        _requireMinted(id);
         
        return string(abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(abi.encodePacked(
                '{"name":"Linkie #',
                Strings.toString(id),
                '","description":"Take care of your Linkie anon!","image":"data:image/svg+xml;base64,',
                Base64.encode(bytes(_tokenSvg(_tokenSvgHash(id)))),
                '","attributes":',
                _tokenAttributes(id),
                '}'
            ))
        ));
    }

    /**
        @notice Withdraw contracts tokens

        @param token Token contract
        @param receiver Receiver of tokens
        @param amount Amount of tokens to withdraw
    */
    function withdraw(address token, address receiver, uint256 amount) external onlyOwner {
        IERC20(token).transfer(receiver, amount);
    }

    function _token(uint256 id) internal view returns (TokenData memory tokenData) {
        return _tokens[id];
    }

    function _randomSpecies(uint256 lifeCycle, uint256 random) internal view returns (uint256) {
        return random % _speciesLengths[lifeCycle];
    }   

    function _lifeCycle(uint256 id) internal view returns (uint256) {
        if (block.number > _tokens[id].lifeCycleBlockstamp + _growthRate && 
            _tokens[id].lifeCycle < _speciesLengths.length) {
            return _tokens[id].lifeCycle + 1;
        }

        return _tokens[id].lifeCycle;
    }

    function _species(uint256 id) internal view returns (uint256) {
        if (block.number > _tokens[id].lifeCycleBlockstamp + _growthRate && 
            _tokens[id].lifeCycle < _speciesLengths.length) {
            return _randomSpecies(_tokens[id].lifeCycle, _blockhashRandom(id, _tokens[id].lifeCycleBlockstamp + _growthRate));
        }

        return _tokens[id].species;
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

    function _newToken(uint256 id, uint256 random) internal {
        _tokens[id].lifeCycleBlockstamp = block.number;
        _tokens[id].species = _randomSpecies(0, random);
        _tokens[id].hungerTimestamp = block.timestamp;
        _tokens[id].sicknessBlockstamp = block.number;
    }

    function _setToken(uint256 id, TokenData memory tokenData) internal {
        _tokens[id] = tokenData;
    }

    function _checkGrowth(uint256 id) internal {
        if(_lifeCycle(id) > _tokens[id].lifeCycle) {
            _tokens[id].lifeCycle++;
            _tokens[id].species = _species(id);
        }
    }

    function _feed(uint256 id, uint256 amount) internal {
        _tokens[id].hunger = _safeSubtraction(_hunger(id), amount);
        _tokens[id].hungerTimestamp = block.timestamp;
    }

    function _heal(uint256 id, uint256 amount) internal {
        _tokens[id].sickness = _safeSubtraction(_sickness(id), amount);
        _tokens[id].sicknessBlockstamp = block.number;
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
            "<svg id='linkie-svg' xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 16 16'><style>#linkie-svg{shape-rendering: crispedges;}.w0{fill:#000000}.w1{fill:#FFFFFF}.w2{fill:#FF0000}.w3{fill:#00FF00}.w4{fill:#0000FF}.w5{fill:#00FFFF}.w6{fill:#FFFF00}.w7{fill:#FF00FF}</style>", 
            rects,
            "</svg>"
        ));
    }

    function _tokenSvgHash(uint256 id) internal view returns (bytes memory) {
        if(_tokens[id].hungerTimestamp == 0) {
            return hex"00";
        }

        if(_tokens[id].lifeCycle == 0) { // Baby
            if(_tokens[id].species == 0) {
                return hex"00D61500C71200A53100AB3100A71100A911009611008711007811008911009A11";
            }
        } else if(_tokens[id].species == 1) { // Child
            if(_tokens[id].species == 0) {
                return hex"00D51600A43100AB3100C81200B61100A811009512009912008712";
            } else if(_tokens[id].species == 1) {
                return hex"00D61400C51100CA1100B71200A61100981100A42100AB21009511008611007712008911009A11";
            }
        } else if(_tokens[id].species == 1) { // Teen
            if(_tokens[id].species == 0) {
                return hex"00C51600D61100D911008441008B41009C1100931100A612008611009911007516";
            } else if(_tokens[id].species == 1) {
                return hex"00C61500A81200D61100DA11008711007911007551006615007B51009C11009411";
            }
        } else if(_tokens[id].species == 1) { // Adult
            if(_tokens[id].species == 0) {
                return hex"00C51600D61100D91100943100A311009B3100AC11008511007614008A1100961100881100A712";
            } else if(_tokens[id].species == 1) {
                return hex"00C51600D61100D911008441008B4100751200871200791200991100A61100B81200AC1100A311";
            }
        }

        return "UNDEFINED";
    }
    
    function _tokenAttributes(uint256 id) internal view returns (string memory) {
        if(_tokens[id].hungerTimestamp == 0) {
            return "[]";
        }

        string memory attributes = string(abi.encodePacked(
            '{"trait_type":"Life cycle","value":"',
            Strings.toString(_lifeCycle(id)),
            '"},',
            '{"trait_type":"Species","value":"',
            Strings.toString(_species(id)),
            '"},',
            '{"trait_type":"Sickness","value":"',
            Strings.toString(_sickness(id)),
            '"},',
            '{"trait_type":"Hunger","value":"',
            Strings.toString(_hunger(id)),
            '"}'
        ));

        return string(abi.encodePacked("[", attributes, "]"));
    }

    function _blockhashRandom(uint256 id, uint256 blockNumber) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(blockhash(blockNumber), id)));
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