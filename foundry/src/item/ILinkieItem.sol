// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ILinkieItem {
    enum ItemType {
        Food,
        Medicine,
        Collectable
    }

    function item(uint256 id) external view returns (ItemType itemType, uint256 amount, uint256 price, uint256 maxMinted, uint256 totalMinted);

    function mint(uint256 id, uint256 amount, address receiver) external;
    function use(uint256 id, uint256 amount, uint256 linkieId) external;

    function newFood(uint256 amount, uint256 price, uint256 maxSupply) external returns (uint256 id);
    function newMedicine(uint256 amount, uint256 price, uint256 maxSupply) external returns (uint256 id);
    function newCollectable(uint256 price, uint256 maxSupply) external returns (uint256 id);

    function withdraw(address token, address receiver, uint256 amount) external;
}