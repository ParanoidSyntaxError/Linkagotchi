import React, {CSSProperties} from 'react';

function Notice(text: string, fontSize: string, width: string, height: string, color: string, bgColor: string) {  
    const rootStyle: CSSProperties = {
        backgroundColor: bgColor,
        width: width,
        height: height,
        borderRadius: "1rem",
        display: "flex",
        justifyContent: "center",
        alignItems: "center"
    };

    const textStyle: CSSProperties = {
        fontFamily: "monospace",
        fontWeight: "bold",
        fontSize: fontSize,
        color: color,
        padding: "1rem",
    };

    return (
        <div style={rootStyle}>
            <div style={textStyle}>
                {text}
            </div>
        </div>
    );
}

export default Notice;