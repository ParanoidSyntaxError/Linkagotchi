import React, {CSSProperties} from 'react';
import { List, ListItem } from '@mui/material';
import Grid from '@mui/material/Unstable_Grid2';
import "./scrollbar.css";

function LinkieList() {  
    const rootStyle: CSSProperties = {
        backgroundColor: "rgba(255, 255, 255, 1)",
        borderRadius: "1rem",
        border: "0.5rem solid pink",
        width: "11rem",
        height: "70vh"
    };

    const cardStyle: CSSProperties = {
        width: "7rem",
        height: "fit-content",
        backgroundColor: "black",
        padding: "0.5rem",
        borderRadius: "0.5rem"
    };

    const imgStyle: CSSProperties = {
        width: "100%",
        borderRadius: "0.5rem"
    };

    const textStyle: CSSProperties = {
        fontFamily: "monospace",
        fontWeight: "bold",
        fontSize: "1rem",
        color: "white"
    };

    return (
        <div style={rootStyle}>
            <Grid container sx={{
                width: "100%",
                height: "100%",
                overflowY: "scroll",
                justifyContent: "left",
                alignItems: "center",
            }}>
                {[...Array(10)].map(() => (
                    <Grid sx={{
                        margin: "1rem 1rem"
                    }}>
                        <div style={cardStyle}>
                            <img src="LinkieBaby.png" style={imgStyle}></img>
                            <div style={textStyle}>
                                Linkie #0
                            </div>
                        </div>
                    </Grid>
                ))}
            </Grid>
        </div>
    );
}

export default LinkieList;