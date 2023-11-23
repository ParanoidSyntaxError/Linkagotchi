import {CSSProperties} from 'react';
import Swing from 'react-reveal/Swing';
import Pulse from 'react-reveal/Pulse';
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
            <Pulse forever duration={10000}>
                <Swing forever duration={10000}>
                    <img src='./LinkieLogo.png' style={imgStyle}></img>
                </Swing>
            </Pulse>
        </div>
    );
}

export default Title;