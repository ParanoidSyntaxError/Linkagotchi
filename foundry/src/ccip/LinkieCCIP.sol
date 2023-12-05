// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IRouterClient} from "@ccip/ccip/interfaces/IRouterClient.sol";
import {Client} from "@ccip/ccip/libraries/Client.sol";
import {CCIPReceiver, IAny2EVMMessageReceiver} from "@ccip/ccip/applications/CCIPReceiver.sol";

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ERC721Enumerable, IERC721Enumerable, ERC721, IERC165} from "@openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";

import {Linkie} from "../Linkie.sol";

import {ILinkieCCIP} from "./ILinkieCCIP.sol";

contract LinkieCCIP is ILinkieCCIP, CCIPReceiver, Linkie {
    struct TokenState {
        uint256 lifeCycle;
        uint256 species;
        uint256 hunger;
        uint256 sickness;
    }
    
    struct MessageData {
        uint256 tokenId;
        address tokenReceiver;
        TokenState tokenState;
    }
    
    mapping(uint64 => address) private _linkieContracts;

    bool public immutable isHomeChain;

    constructor(
        bool isHome,
        uint256 blockMulti,
        address link,
        address vrf,
        address ccipRouter
    ) CCIPReceiver(
        ccipRouter
    ) Linkie(
        blockMulti,
        link,
        vrf
    ) {
        isHomeChain = isHome;
    }

    function supportsInterface(bytes4 interfaceId) public pure virtual override (CCIPReceiver, ERC721Enumerable, IERC165) returns (bool) {
        return (
            interfaceId == type(IAny2EVMMessageReceiver).interfaceId || 
            interfaceId == type(IERC721Enumerable).interfaceId ||
            interfaceId == type(IERC165).interfaceId
        );
    }

    function mint(address receiver, uint256 vrfFee, bytes32 keyHash, uint32 callbackGasLimit) public virtual override returns (uint256 requestId, uint256 id) {      
        require(isHomeChain);

        return super.mint(receiver, vrfFee, keyHash, callbackGasLimit);
    }

    function getLinkieContract(uint64 destinationChainSelector) external view returns (address) {
        return _linkieContracts[destinationChainSelector];
    }

    function setLinkieContract(uint64 destinationChainSelector, address linkagotchi) external onlyOwner() {
        _linkieContracts[destinationChainSelector] = linkagotchi;
    }

    function ccipTransfer(uint256 id, address receiver, uint64 destinationChainSelector, address feeToken, bytes memory extraArgs) external payable returns (bytes32) {
        require(_ownerOf(id) == msg.sender);

        _burn(id);
        
        TokenData memory tokenData = _token(id);

        TokenState memory tokenState = TokenState(
            tokenData.lifeCycle, 
            tokenData.species,
            _sickness(id),
            _hunger(id)
        );

        MessageData memory messageData = MessageData(id, receiver, tokenState);

        Client.EVM2AnyMessage memory ccipMessage = Client.EVM2AnyMessage(
            abi.encode(_linkieContracts[destinationChainSelector]),
            abi.encode(messageData),
            new Client.EVMTokenAmount[](0),
            feeToken,
            extraArgs
        );

        IRouterClient router = IRouterClient(this.getRouter());

        uint256 feeAmount = router.getFee(destinationChainSelector, ccipMessage);

        // Pay with native coin
        if(feeToken == address(0)) {
            require(feeAmount >= address(this).balance);

            return router.ccipSend{value: feeAmount}(destinationChainSelector, ccipMessage);
        }

        // Pay with token
        IERC20(feeToken).transferFrom(msg.sender, address(this), feeAmount);
        IERC20(feeToken).approve(address(router), feeAmount);

        return router.ccipSend(destinationChainSelector, ccipMessage);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        require(abi.decode(message.sender, (address)) == _linkieContracts[message.sourceChainSelector]);

        MessageData memory messageData = abi.decode(message.data, (MessageData));

        TokenData memory tokenData = TokenData(
            messageData.tokenState.lifeCycle,
            block.number,
            messageData.tokenState.species,
            messageData.tokenState.hunger,
            block.timestamp,
            messageData.tokenState.sickness,
            block.number
        );
        _setToken(messageData.tokenId, tokenData);

        _safeMint(messageData.tokenReceiver, messageData.tokenId);
    }
}