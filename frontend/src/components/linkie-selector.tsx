import React, {CSSProperties} from 'react';
import { Stack } from '@mui/material';

function LinkieSelector() {  
    const rootStyle: CSSProperties = {
    };

    const cardStyle: CSSProperties = {
        width: "12rem",
        height: "14rem",
        backgroundColor: "red"
    };

    const imgStyle: CSSProperties = {
        width: "100%"
    };

    const textStyle: CSSProperties = {
        fontFamily: "monospace",
        fontWeight: "bold",
        fontSize: "1rem"
    };

    /*
        fontFamily: "monospace",
        fontWeight: "bold",
        fontSize: fontSize,
        color: "white",
        backgroundColor: bgColor,
        '&:hover': {
            color: "black",
            backgroundColor: bgColorHover,
        },
        border: "0.25rem solid black",
        width: width,
        borderRadius: "1rem",
        padding: "0 1rem"
    */

    return (
        <div style={rootStyle}>
            <Stack direction="column">
                <div style={cardStyle}>
                    <img src="LinkieBaby.png" style={imgStyle}></img>
                    <div style={textStyle}>
                        Linkie #0
                    </div>
                </div>
            </Stack>
        </div>
    );
}

export default LinkieSelector;