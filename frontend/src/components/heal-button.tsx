import React, {CSSProperties} from 'react';
import Button from "../components/button";
import { useContractWrite } from 'wagmi';
import { encodeAbiParameters, hexToBigInt, stringToHex, numberToHex } from 'viem';
import LinkieStats from '../interfaces/linkie-stats';

export default function HealButton(text: string, fontSize: string, width: string, bgColor: string, bgColorHover: string, linkie: LinkieStats) {  
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
        [BigInt(2), encodedTokenId]
    );

    const { write } = useContractWrite({
        address: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
        abi: transferAndCallAbi,
        args: [
            "0x1993aD4D968664b96c613173C785ba860c1100dB", 
            101,
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