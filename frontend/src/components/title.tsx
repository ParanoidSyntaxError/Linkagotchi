import {CSSProperties} from 'react';
import { Property } from 'csstype'

function Title(align: Property.TextAlign, margin: string, width: string, maxWidth: string) {
    const rootStyle: CSSProperties = {
        width: "95vw",
        height: "95vh",
        overflow: "hidden",
        position: "absolute",
        textAlign: align,
        pointerEvents: "none"
    };

    const imgStyle: CSSProperties = {
        width: width,
        maxWidth: maxWidth,
        margin: margin,
    };

    return (
        <div style={rootStyle}>
            <img src='./LinkieLogo.png' style={imgStyle}></img>
        </div>
    );
}

export default Title;