import React, {CSSProperties} from 'react';
import Button from "../components/button";
import { useContractWrite } from 'wagmi';
import { encodeAbiParameters, hexToBigInt, stringToHex, numberToHex } from 'viem';
import LinkieStats from '../interfaces/linkie-stats';

export default function FeedButton(text: string, fontSize: string, width: string, bgColor: string, bgColorHover: string, linkie: LinkieStats) {  
    const rootStyle: CSSProperties = {
    };

    const transferAndCallAbi = [{
        "constant": false,
        "inputs": [
        {
            "name": "_to",
            "type": "address"
        },
        {
            "name": "_value",
            "type": "uint256"
        },
        {
            "name": "_data",
            "type": "bytes"
        }
        ],
        "name": "transferAndCall",
        "outputs": [
        {
            "name": "success",
            "type": "bool"
        }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    }];

    const encodedTokenId = encodeAbiParameters(
        [
            {name: "id", type: "uint256"}
        ],
        [linkie.tokenId]
    );

    const encodedArgs = encodeAbiParameters(
        [
            {name: "callType", type: "uint256"},
            {name: "callData", type: "bytes"}
        ],
        [BigInt(1), encodedTokenId]
    );

    const { write } = useContractWrite({
        address: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
        abi: transferAndCallAbi,
        args: [
            "0xef3E58DEAd252D80e95edf19CfFB268637090A4a", 
            110000,
            encodedArgs
        ],
        functionName: "transferAndCall"
    });

    return (
        <div style={rootStyle}>
            {Button(text, fontSize, width, bgColor, bgColorHover, write)}            
        </div>
    );
}