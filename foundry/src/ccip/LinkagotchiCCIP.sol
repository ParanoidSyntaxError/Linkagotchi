// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IRouterClient} from "@ccip/ccip/interfaces/IRouterClient.sol";
import {Client} from "@ccip/ccip/libraries/Client.sol";
import {CCIPReceiver, IAny2EVMMessageReceiver} from "@ccip/ccip/applications/CCIPReceiver.sol";

import {ERC721, IERC721} from "@openzeppelin/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {IERC165} from "@openzeppelin/utils/introspection/IERC165.sol";

import {Linkagotchi} from "../Linkagotchi.sol";

contract LinkagotchiCCIP is CCIPReceiver, Linkagotchi {
    struct MessageData {
        uint256 tokenId;
        address tokenReceiver;
        TokenData tokenData;
    }
    
    mapping(uint64 => address) internal _linkagotchiContracts;

    constructor(
        address accountRegistry, 
        address accountImplementation, 
        uint256 accountChainId,
        address linkToken,
        address vrfCoordinator,
        address ccipRouter
    ) CCIPReceiver(
        ccipRouter
    ) Linkagotchi(
        accountRegistry, 
        accountImplementation, 
        accountChainId,
        linkToken,
        vrfCoordinator
    ) {}

    function supportsInterface(bytes4 interfaceId) public pure override (CCIPReceiver, ERC721, IERC165) returns (bool) {
        return (
            interfaceId == type(IAny2EVMMessageReceiver).interfaceId || 
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId
        );
    }

    function ccipTransfer(uint256 id, address receiver, uint64 destinationChainSelector, address feeToken) external payable returns (bytes32) {
        require(_ownerOf(id) == msg.sender);

        _burn(id);
        
        MessageData memory messageData = MessageData(id, receiver, _token(id));

        Client.EVM2AnyMessage memory ccipMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(_linkagotchiContracts[destinationChainSelector]),
            data: abi.encode(messageData),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            feeToken: feeToken,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000})
            )
        });

        IRouterClient router = IRouterClient(this.getRouter());

        uint256 feeAmount = router.getFee(destinationChainSelector, ccipMessage);

        if(feeToken == address(0)) {
            require(feeAmount >= address(this).balance);
        } else {
            IERC20(feeToken).transferFrom(msg.sender, address(this), feeAmount);
            IERC20(feeToken).approve(address(router), feeAmount);
        }

        return router.ccipSend(destinationChainSelector, ccipMessage);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        MessageData memory messageData = abi.decode(message.data, (MessageData));

        _setToken(messageData.tokenId, messageData.tokenData);

        _safeMint(messageData.tokenReceiver, messageData.tokenId);
    }
}