import React, {CSSProperties} from 'react';
import { Stack } from '@mui/material';
import Grid from '@mui/material/Unstable_Grid2';
import Button from "../components/button";
import LinkieList from '../components/linkie-list';
import LinkiePortrait from '../components/linkie-portrait';
import ConnectButton from '../components/connect-button';
import { useAccount, useContractWrite } from 'wagmi';
import MintButton from './mint-button';

export default function GameView() {  
    const rootStyle: CSSProperties = {
        marginBottom: "4rem"
    };

    const gameButtonsStyle: CSSProperties = {
    };

    const gridStyle: CSSProperties = {
        marginTop: "1rem"
    };

    const connectStyle: CSSProperties = {
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        marginTop: "8rem",
        marginBottom: "4rem"
    };

    const { isConnected } = useAccount()

    if(isConnected == false) {
        return (
            <div style={connectStyle}>
                <ConnectButton/>
            </div>
        );
    }

    return (
        <div style={rootStyle}>
            <div style={gameButtonsStyle}>
                <Stack direction="row" justifyContent="center" spacing={8}>
                    {MintButton("MINT", "1rem", "5rem", "deeppink", "aqua")}
                    {Button("FEED", "1rem", "5rem", "deeppink", "aqua")}
                    {Button("HEAL", "1rem", "5rem", "deeppink", "aqua")}
                </Stack>
            </div>
            <div style={gridStyle}>
                <Grid container margin="0 auto" rowGap="2rem" columnGap="2rem" sx={{
                    justifyContent: "center",
                    alignItems: "center",
                    width: "100vh",
                    maxWidth: "90vw",
                }}>
                    <div>
                        <LinkieList/>
                    </div>
                    <div>
                        <LinkiePortrait/>
                    </div>
                </Grid>
            </div>
        </div>
    );
}