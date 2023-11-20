import React, {CSSProperties} from 'react';
import { Stack } from '@mui/material';
import Title from "../components/title";
import Button from "../components/button";
import LinkieSelector from '../components/linkie-selector';

function Game() {  
    const rootStyle: CSSProperties = {
    };

    const headerStyle: CSSProperties = {
        height: "8rem"
    };

    const titleStyle: CSSProperties = {
    };

    const connectBtnStyle: CSSProperties = {
        position: "absolute",
        right: "0",
        margin: "2rem 2rem"
    };

    const navigationStyle: CSSProperties = {
    };

    return (
        <div style={rootStyle}>
            <div style={headerStyle}>
                <div style={titleStyle}>
                    {Title("left", "2rem 4rem", "8rem", "8rem")}   
                </div>
                <div style={connectBtnStyle}>
                    {Button("Connect wallet", "2rem", "fit-content", "deeppink", "aqua")}
                </div>
            </div>
            <div style={navigationStyle}>
                <Stack direction="row" justifyContent="center" spacing={8}>
                    {Button("Linkie", "1rem", "5rem", "deeppink", "aqua")}
                    {Button("Shop", "1rem", "5rem", "deeppink", "aqua")}
                </Stack>
            </div>
            <div>
                {LinkieSelector()}
            </div>
        </div>
    );
}

export default Game;