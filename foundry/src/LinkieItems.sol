// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ERC1155Supply, ERC1155} from "@openzeppelin/token/ERC1155/extensions/ERC1155Supply.sol";

import {ILinkagotchi} from "./ILinkagotchi.sol";

contract LinkieItems is ERC1155Supply, Ownable {
    enum ItemType {
        Food,
        Medicine,
        Collectable
    }
    
    struct TokenData {
        ItemType itemType;
        uint256 amount;
        uint256 price;
        uint256 maxSupply;
    }

    address public immutable linkagotchi;
    address public immutable linkToken;

    mapping(uint256 => TokenData) private _tokenData;
    uint256 private _totalIds;

    uint256 private _excessLink;

    constructor(string memory uri, address linkagotchiContract, address linkTokenContract) ERC1155(uri) {
        linkagotchi = linkagotchiContract;
        linkToken = linkTokenContract;

        IERC20(linkToken).approve(linkagotchiContract, type(uint256).max);
    }

    function mint(uint256 id, uint256 amount, address receiver) external {
        require(id < _totalIds);

        uint256 cost = _tokenData[id].price * amount;
        IERC20(linkToken).transferFrom(msg.sender, address(this), cost);

        if(_tokenData[id].itemType == ItemType.Food) {
            cost -= ILinkagotchi(linkagotchi).feedCost() * amount;

        } else if(_tokenData[id].itemType == ItemType.Medicine) {
            cost -= ILinkagotchi(linkagotchi).healCost() * amount;
        }
        _excessLink += cost;
        
        _mint(receiver, id, amount, "");
    }

    function use(uint256 id, uint256 amount, uint256 linkieId) external {
        require(amount > 0);

        _burn(msg.sender, id, amount);

        if(_tokenData[id].itemType == ItemType.Food) {
            ILinkagotchi(linkagotchi).feed(linkieId, _tokenData[id].amount);
            return;
        } else if(_tokenData[id].itemType == ItemType.Medicine) {
            ILinkagotchi(linkagotchi).heal(linkieId, _tokenData[id].amount);
            return;
        }

        revert();
    }

    function newFood(uint256 amount, uint256 price, uint256 maxSupply) external onlyOwner() returns (uint256 id) {
        id = _totalIds;

        uint256 minCost = ILinkagotchi(linkagotchi).feedCost() * amount;
        require(price >= minCost);

        _tokenData[id] = TokenData(ItemType.Food, amount, price, maxSupply);

        _totalIds++;
    }

    function newMedicine(uint256 amount, uint256 price, uint256 maxSupply) external onlyOwner() returns (uint256 id) {
        id = _totalIds;

        uint256 minCost = ILinkagotchi(linkagotchi).healCost() * amount;
        require(price >= minCost);

        _tokenData[id] = TokenData(ItemType.Medicine, amount, price, maxSupply);

        _totalIds++;
    }

    function newCollectable(uint256 price, uint256 maxSupply) external onlyOwner() returns (uint256 id) {
        id = _totalIds;

        _tokenData[id].itemType = ItemType.Collectable;
        _tokenData[id].price = price;
        _tokenData[id].maxSupply = maxSupply;

        _totalIds++;
    }

    /**
        @notice Withdraw contracts tokens

        @param token Token contract
        @param receiver Receiver of tokens
        @param amount Amount of tokens to withdraw
    */
    function withdraw(address token, address receiver, uint256 amount) external onlyOwner {
        if(token == linkToken) {
            _excessLink -= amount;
        }

        IERC20(token).transfer(receiver, amount);
    }    
}