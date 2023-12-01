import React, {CSSProperties} from 'react';
import Title from "../components/title";
import ConnectButton from '../components/connect-button';

function GameHeader() {  
    const rootStyle: CSSProperties = {
        height: "7rem"
    };

    const connectBtnStyle: CSSProperties = {
        position: "absolute",
        right: "0",
        margin: "2rem 2rem"
    };

    return (
        <div style={rootStyle}>
            <div>
                {Title("left", "2rem 4rem", "8rem", "8rem")}   
            </div>
            <div style={connectBtnStyle}>
                {ConnectButton()}
            </div>
        </div>
    );
}

export default GameHeader;