import React, {CSSProperties} from 'react';
import GameHeader from '../components/game-header';
import GameView from '../components/game-view';

import { createWeb3Modal, defaultWagmiConfig, useWeb3Modal } from '@web3modal/wagmi/react';
import { WagmiConfig } from 'wagmi';
import { polygonMumbai } from 'viem/chains';

const projectId = '7658bba07fe609dfc3e33c491170ef61';
const chains = [polygonMumbai];
const wagmiConfig = defaultWagmiConfig({ chains, projectId });
createWeb3Modal({ wagmiConfig, projectId, chains });

function Game() {  
    const rootStyle: CSSProperties = {
    };

    return (
        <WagmiConfig config={wagmiConfig}>
            <div style={rootStyle}>
                <div>
                    <GameHeader/>
                </div>
                <div>
                    <GameView/>
                </div>
            </div>
        </WagmiConfig>
    );
}

export default Game;