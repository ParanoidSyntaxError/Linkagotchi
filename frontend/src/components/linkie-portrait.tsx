import React, {CSSProperties} from 'react';

function LinkiePortrait() {  
    const rootStyle: CSSProperties = {
        backgroundColor: "white",
        borderRadius: "1rem",
        border: "0.5rem solid yellow",
        width: "70vh",
        maxWidth: "90vw",
        height: "70vh",
        maxHeight: "90vw",
    };

    const imgStyle: CSSProperties = {
        width: "100%",
        height: "100%"
    };

    return (
        <div style={rootStyle}>
            <img src="./LandscapeBackground.png" style={imgStyle}></img>
        </div>
    );
}

export default LinkiePortrait;