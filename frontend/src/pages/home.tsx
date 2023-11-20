import React, {CSSProperties} from 'react';
import Title from "../components/title";

function Home() {  
    const rootStyle: CSSProperties = {
    };

    const titleStyle: CSSProperties = {
        height: "32rem"
    };

    return (
        <div style={rootStyle}>
            <div style={titleStyle}>
                {Title("center", "8rem 0", "40vw", "32rem")}   
            </div>
        </div>
    );
}

export default Home;