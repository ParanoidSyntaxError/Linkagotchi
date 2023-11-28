// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ERC1155Supply, ERC1155} from "@openzeppelin/token/ERC1155/extensions/ERC1155Supply.sol";

import {ILinkie} from "./ILinkie.sol";
import {ILinkieItem} from "./ILinkieItem.sol";

contract LinkieItem is ILinkieItem, ERC1155Supply, Ownable {   
    struct TokenData {
        ItemType itemType;
        uint256 amount;
        uint256 price;
        uint256 maxMinted;
        uint256 totalMinted;
    }

    address public immutable linkie;
    address public immutable linkToken;

    mapping(uint256 => TokenData) private _tokenData;
    uint256 private _totalIds;

    uint256 private _excessLink;

    constructor(string memory uri, address linkieContract, address linkTokenContract) ERC1155(uri) {
        linkie = linkieContract;
        linkToken = linkTokenContract;

        IERC20(linkToken).approve(linkieContract, type(uint256).max);
    }

    function item(uint256 id) external view override returns (ItemType itemType, uint256 amount, uint256 price, uint256 maxMinted, uint256 totalMinted) {
        return (_tokenData[id].itemType, _tokenData[id].amount, _tokenData[id].price, _tokenData[id].maxMinted, _tokenData[id].totalMinted);
    }

    function mint(uint256 id, uint256 amount, address receiver) external override {
        require(id < _totalIds);
        require(_tokenData[id].totalMinted <= _tokenData[id].maxMinted);

        uint256 cost = _tokenData[id].price * amount;
        IERC20(linkToken).transferFrom(msg.sender, address(this), cost);

        if(_tokenData[id].itemType == ItemType.Food) {
            cost -= ILinkie(linkie).feedCost() * amount;

        } else if(_tokenData[id].itemType == ItemType.Medicine) {
            cost -= ILinkie(linkie).healCost() * amount;
        }
        _excessLink += cost;
        
        _tokenData[id].totalMinted++;

        _mint(receiver, id, amount, "");

        emit Mint(id, amount, receiver);
    }

    function use(uint256 id, uint256 amount, uint256 linkieId) external override {
        require(amount > 0);

        _burn(msg.sender, id, amount);

        if(_tokenData[id].itemType == ItemType.Food) {
            ILinkie(linkie).feed(linkieId, _tokenData[id].amount);
            
            emit Use(id, amount, linkieId);
            
            return;
        } else if(_tokenData[id].itemType == ItemType.Medicine) {
            ILinkie(linkie).heal(linkieId, _tokenData[id].amount);

            emit Use(id, amount, linkieId);
            
            return;
        }

        revert();
    }

    function setURI(string memory uri) external override onlyOwner() {
        _setURI(uri);
    }

    function newFood(uint256 amount, uint256 price, uint256 maxMinted) external override onlyOwner() returns (uint256 id) {
        id = _totalIds;

        uint256 minCost = ILinkie(linkie).feedCost() * amount;
        require(price >= minCost);

        _tokenData[id].itemType = ItemType.Food;
        _tokenData[id].amount = amount;
        _tokenData[id].price = price;
        _tokenData[id].maxMinted = maxMinted;

        _totalIds++;
    }

    function newMedicine(uint256 amount, uint256 price, uint256 maxMinted) external override onlyOwner() returns (uint256 id) {
        id = _totalIds;

        uint256 minCost = ILinkie(linkie).healCost() * amount;
        require(price >= minCost);

        _tokenData[id].itemType = ItemType.Medicine;
        _tokenData[id].amount = amount;
        _tokenData[id].price = price;
        _tokenData[id].maxMinted = maxMinted;

        _totalIds++;
    }

    function newCollectable(uint256 price, uint256 maxMinted) external override onlyOwner() returns (uint256 id) {
        id = _totalIds;

        _tokenData[id].itemType = ItemType.Collectable;
        _tokenData[id].price = price;
        _tokenData[id].maxMinted = maxMinted;

        _totalIds++;
    }

    /**
        @notice Withdraw contracts tokens

        @param token Token contract
        @param receiver Receiver of tokens
        @param amount Amount of tokens to withdraw
    */
    function withdraw(address token, address receiver, uint256 amount) external override onlyOwner() {
        if(token == linkToken) {
            _excessLink -= amount;
        }

        IERC20(token).transfer(receiver, amount);
    }    
}