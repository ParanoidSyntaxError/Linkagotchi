// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ILinkieItem {
    enum ItemType {
        Food,
        Medicine,
        Collectable
    }

    event Mint(uint256 indexed id, uint256 amount, address indexed receiver);
    event Use(uint256 indexed id, uint256 amount, uint256 indexed linkieId);

    function item(uint256 id) external view returns (ItemType itemType, uint256 amount, uint256 price, uint256 maxMinted, uint256 totalMinted);
    function totalIds() external view returns (uint256 total);

    function mint(uint256 id, uint256 amount, address receiver) external;
    function use(uint256 id, uint256 amount, uint256 linkieId) external;

    function setURI(string memory uri) external;

    function newFood(uint256 amount, uint256 price, uint256 maxSupply) external returns (uint256 id);
    function newMedicine(uint256 amount, uint256 price, uint256 maxSupply) external returns (uint256 id);
    function newCollectable(uint256 price, uint256 maxSupply) external returns (uint256 id);

    function withdraw(address token, address receiver, uint256 amount) external;
}