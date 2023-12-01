import React, {CSSProperties} from 'react';
import GameHeader from '../components/game-header';
import GameView from '../components/game-view';
import Notice from '../components/notice';

import { createWeb3Modal, defaultWagmiConfig, useWeb3Modal } from '@web3modal/wagmi/react';
import { WagmiConfig } from 'wagmi';
import { arbitrum, mainnet } from 'viem/chains';

// Wallet connect
const projectId = '7658bba07fe609dfc3e33c491170ef61';
const chains = [mainnet, arbitrum];
const wagmiConfig = defaultWagmiConfig({ chains, projectId });
createWeb3Modal({ wagmiConfig, projectId, chains });

function Game() {  
    const rootStyle: CSSProperties = {
    };

    const noticeStyle: CSSProperties = {
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        marginTop: "8rem",
        marginBottom: "4rem"
    };

    const view = () => {
        if(false) {
            return GameView();
        }
    
        return (
            <div style={noticeStyle}>
                {Notice("Please connect your wallet", "1.75rem", "fit-content", "fit-content", "black", "coral")}
            </div>
        );
    };

    return (
        <WagmiConfig config={wagmiConfig}>
            <div style={rootStyle}>
                <div>
                    {GameHeader()}
                </div>
                <div>
                    {view()}
                </div>
            </div>
        </WagmiConfig>
    );
}

export default Game;