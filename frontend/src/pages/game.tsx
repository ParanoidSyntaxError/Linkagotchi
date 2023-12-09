import React, {CSSProperties} from 'react';
import GameHeader from '../components/game-header';
import GameView from '../components/game-view';
import ConnectButton from '../components/connect-button';

import { createWeb3Modal, defaultWagmiConfig, useWeb3Modal } from '@web3modal/wagmi/react';
import { WagmiConfig, useAccount } from 'wagmi';
import { polygonMumbai } from 'viem/chains';

import { QueryClient, QueryClientProvider, useQuery } from 'react-query';

const projectId = '7658bba07fe609dfc3e33c491170ef61';
const chains = [polygonMumbai];
const wagmiConfig = defaultWagmiConfig({ chains, projectId });
createWeb3Modal({ wagmiConfig, projectId, chains });

const queryClient = new QueryClient()

function View() {
    const connectStyle: CSSProperties = {
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        marginTop: "8rem",
        marginBottom: "4rem"
    };

    const { isConnected } = useAccount();

    if(isConnected) {
        return (
            <GameView/>
        );
    }

    return (
        <div style={connectStyle}>
            <ConnectButton/>
        </div>
    );
}

function Game() {  
    const rootStyle: CSSProperties = {
    };

    return (
        <WagmiConfig config={wagmiConfig}>
            <QueryClientProvider client={queryClient}>
                <div style={rootStyle}>
                    <div>
                        <GameHeader/>
                    </div>
                    <div>
                        <View/>
                    </div>
                </div>
            </QueryClientProvider>
        </WagmiConfig>
    );
}

export default Game;