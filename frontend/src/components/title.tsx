import React, {CSSProperties} from 'react';
import Swing from 'react-reveal/Swing';
import Pulse from 'react-reveal/Pulse';

function Title() {
    const rootStyle: CSSProperties = {
        width: '100vw',
        height: '100vh',
        overflow: 'hidden',
        textAlign: 'center',
    };

    const imgStyle: CSSProperties = {
    };

    return (
        <div style={rootStyle}>
            <Pulse forever duration={5000}>
                <Swing forever duration={25000}>
                    <img src='./LinkieLogo.png' style={imgStyle}></img>
                </Swing>
            </Pulse>
        </div>
    );
}

export default Title;