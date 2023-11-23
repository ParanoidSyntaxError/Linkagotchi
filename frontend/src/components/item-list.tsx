import React, {CSSProperties} from 'react';
import Grid from '@mui/material/Unstable_Grid2';
import "./scrollbar.css";

function ItemList() {  
    const rootStyle: CSSProperties = {
        backgroundColor: "white",
        borderRadius: "1rem",
        border: "0.5rem solid pink",
        width: "96vh",
        maxWidth: "90vw",
        height: "20rem",
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
            <Grid container padding={2} gap={2} sx={{
                width: "100%",
                height: "100%",
                overflowY: "scroll",
                justifyContent: "left",
                alignItems: "left",
            }}>
                {[...Array(17)].map(() => (
                    <Grid sx={{
                        //margin: "1rem 1rem"
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

export default ItemList;