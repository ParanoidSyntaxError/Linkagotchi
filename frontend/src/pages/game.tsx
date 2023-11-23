import React, {CSSProperties} from 'react';
import { Stack } from '@mui/material';
import Grid from '@mui/material/Unstable_Grid2';
import Title from "../components/title";
import Button from "../components/button";
import LinkieList from '../components/linkie-list';
import ItemList from '../components/item-list';
import LinkiePortrait from '../components/linkie-portrait';

function Game() {  
    const rootStyle: CSSProperties = {
        marginBottom: "4rem"
    };

    const headerStyle: CSSProperties = {
        height: "7rem"
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

    const gridStyle: CSSProperties = {
        marginTop: "1rem"
    };

    return (
        <div style={rootStyle}>
            <div style={headerStyle}>
                <div style={titleStyle}>
                    {Title("left", "2rem 4rem", "8rem", "8rem")}   
                </div>
                <div style={connectBtnStyle}>
                    {Button("Connect wallet", "1.5rem", "fit-content", "deeppink", "aqua")}
                </div>
            </div>
            <div style={navigationStyle}>
                <Stack direction="row" justifyContent="center" spacing={8}>
                    {Button("Linkie", "1rem", "5rem", "deeppink", "aqua")}
                    {Button("Shop", "1rem", "5rem", "deeppink", "aqua")}
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
                        {LinkieList()}
                    </div>
                    <div>
                        {LinkiePortrait()}
                    </div>
                    <div>
                        {ItemList()}
                    </div>
                </Grid>
            </div>
        </div>
    );
}

export default Game;