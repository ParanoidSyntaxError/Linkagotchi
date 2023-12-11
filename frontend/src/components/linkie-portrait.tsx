import { Stack } from '@mui/material';
import React, {CSSProperties} from 'react';
import LinkieStats from '../interfaces/linkie-stats';

function LinkiePortrait(linkie: LinkieStats | undefined) {  
    const rootStyle: CSSProperties = {
        borderRadius: "1rem",
        border: "0.5rem solid yellow",
        width: "70vh",
        maxWidth: "90vw",
        height: "70vh",
        maxHeight: "90vw",
        backgroundColor: "rgba(255, 255, 255, 0.75)",
        position: "relative"
    };

    const imgContainer: CSSProperties = {
        width: "80%",
        height: "80%",
        margin: "10% 10%"
    };

    const imgStyle: CSSProperties = {
        width: "100%",
        height: "100%",
    };

    const linkieImg = () => {
        if(linkie == undefined) {
            return undefined;
        }

        return (
            <img src={linkie?.lifeCycle + "_" + linkie?.species + ".png"} style={imgStyle}></img>
        );
    };

    const statsContainerStyle: CSSProperties = {
        position: "absolute",
        top: "0",
        margin: "1rem",
    };

    const statStyle: CSSProperties = {
        fontFamily: "monospace",
        fontSize: "1rem",
        border: "black solid 0.15rem",
        borderRadius: "0.5rem",
        padding: "0.25rem",
        backgroundColor: "rgba(255,255,255,0.75)"
    };

    return (
        <div style={rootStyle}>
            <div style={imgContainer}>
                {linkieImg()}
            </div>
            <div style={statsContainerStyle}>
                <Stack direction="row" columnGap="1rem">
                    <div style={statStyle}>
                        {"Alive: " + linkie?.alive.toString()}
                    </div>
                    <div style={statStyle}>
                        {"Hunger: " + linkie?.hunger.toString()}
                    </div>
                    <div style={statStyle}>
                        {"Sickness: " + linkie?.sickness.toString()}
                    </div>
                    <div style={statStyle}>
                        {"Network: " + linkie?.network.toString()}
                    </div>
                </Stack>
            </div>
        </div>
    );
}

export default LinkiePortrait;