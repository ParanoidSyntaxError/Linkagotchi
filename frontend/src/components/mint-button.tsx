import React, {CSSProperties} from 'react';
import Button from "../components/button";
import { useContractWrite } from 'wagmi';

export default function MintButton(text: string, fontSize: string, width: string, bgColor: string, bgColorHover: string) {  
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

    const { write } = useContractWrite({
        address: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
        abi: transferAndCallAbi,
        args: [
            "0xC128D4261c70e8E5d52F45697698468C200Ab538", 
            110000000000000000,
            "0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000404b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f00000000000000000000000000000000000000000000000000000000001e8480"
        ],
        functionName: "transferAndCall"
    });

    return (
        <div style={rootStyle}>
            {Button(text, fontSize, width, bgColor, bgColorHover, write)}            
        </div>
    );
}