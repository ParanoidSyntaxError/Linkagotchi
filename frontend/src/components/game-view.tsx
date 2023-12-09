import React, {CSSProperties} from 'react';
import { Stack } from '@mui/material';
import Grid from '@mui/material/Unstable_Grid2';
import LinkieList from '../components/linkie-list';
import LinkiePortrait from '../components/linkie-portrait';
import MintButton from './mint-button';
import FeedButton from './feed-button';
import HealButton from './heal-button';
import LinkieStats from '../interfaces/linkie-stats';

export default function GameView() {  
    const { view: linkieList, selectedLinkie: selectedLinkie } = LinkieList();
    const nullLinkie = {tokenId: BigInt("0")} as LinkieStats;

    const rootStyle: CSSProperties = {
        marginBottom: "4rem"
    };

    const gameButtonsStyle: CSSProperties = {
    };

    const visability = () => {
        if(selectedLinkie != undefined) {
            return "visible";
        }
        return "hidden";
    };
    const conditionalButton: CSSProperties = {
        visibility: visability()
    };

    const gridStyle: CSSProperties = {
        marginTop: "1rem"
    };

    return (
        <div style={rootStyle}>
            <div style={gameButtonsStyle}>
                <Stack direction="row" justifyContent="center" spacing={8}>
                    {MintButton("MINT", "1rem", "5rem", "deeppink", "aqua")}
                    <div style={conditionalButton}>
                        {FeedButton("FEED", "1rem", "5rem", "deeppink", "aqua", selectedLinkie != undefined ? selectedLinkie : nullLinkie)}
                    </div>
                    <div style={conditionalButton}>
                        {HealButton("HEAL", "1rem", "5rem", "deeppink", "aqua", selectedLinkie != undefined ? selectedLinkie : nullLinkie)}
                    </div>
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
                        {linkieList}
                    </div>
                    <div>
                        {LinkiePortrait(selectedLinkie)}
                    </div>
                </Grid>
            </div>
        </div>
    );
}