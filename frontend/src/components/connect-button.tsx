import React, {CSSProperties} from 'react';
import Button from "../components/button";
import { useWeb3Modal } from '@web3modal/wagmi/react'

export default function ConnectButton() {  
    const rootStyle: CSSProperties = {
    };

    const { open } = useWeb3Modal();

    return (
        <div style={rootStyle}>
            {Button("Connect wallet", "1.5rem", "fit-content", "deeppink", "aqua", open)}            
        </div>
    );
}