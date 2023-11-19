// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ILinkagotchiCCIP {
    function setLinkagotchiContract(uint64 destinationChainSelector, address linkagotchi) external;
    function getLinkagotchiContract(uint64 destinationChainSelector) external view returns (address);

    function ccipTransfer(uint256 id, address receiver, uint64 destinationChainSelector, address feeToken, bytes memory extraArgs) external payable returns (bytes32);
}