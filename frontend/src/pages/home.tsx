import React, {CSSProperties} from 'react';
import Title from "../components/title";

function Home() {  
    const titleStyle: CSSProperties = {
    };

    return (
        <div>
            <div style={titleStyle}>
                {Title()}   
            </div>
        </div>
    );
}

export default Home;