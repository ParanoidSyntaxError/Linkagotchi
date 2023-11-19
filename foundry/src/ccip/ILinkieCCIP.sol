// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ILinkieCCIP {
    function setLinkieContract(uint64 destinationChainSelector, address linkie) external;
    function getLinkieContract(uint64 destinationChainSelector) external view returns (address);

    function ccipTransfer(uint256 id, address receiver, uint64 destinationChainSelector, address feeToken, bytes memory extraArgs) external payable returns (bytes32);
}