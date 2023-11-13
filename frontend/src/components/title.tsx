import Swing from 'react-reveal/Swing';
import Pulse from 'react-reveal/Pulse';

function Title() {
    return (
        <div>
            <Pulse forever duration={5000}>
                <Swing forever duration={25000}>
                    <img src='./LinkagotchiLogoInverted.png'></img>
                </Swing>
            </Pulse>
        </div>
    );
}

export default Title;