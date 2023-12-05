import React, {CSSProperties} from 'react';
import Title from "../components/title";

function GameHeader() {  
    const rootStyle: CSSProperties = {
        height: "7rem"
    };

    return (
        <div style={rootStyle}>
            <div>
                {Title("left", "2rem 4rem", "8rem", "8rem")}   
            </div>
        </div>
    );
}

export default GameHeader;