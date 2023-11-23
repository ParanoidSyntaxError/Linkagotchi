import React, {CSSProperties} from 'react';
import { styled } from '@mui/material/styles';
import MuiButton, { ButtonProps as MuiButtonProps } from '@mui/material/Button';

function Button(text: string, fontSize: string, width: string, bgColor: string, bgColorHover: string) {  
    const rootStyle: CSSProperties = {
    };

    const StyledButton = styled(MuiButton)<MuiButtonProps>(() => ({
        fontFamily: "monospace",
        fontWeight: "bold",
        fontSize: fontSize,
        color: "white",
        backgroundColor: bgColor,
        '&:hover': {
            color: "black",
            backgroundColor: bgColorHover,
        },
        border: "0.25rem solid black",
        width: width,
        borderRadius: "1rem",
        padding: "0 1rem"
    }));

    return (
        <div style={rootStyle}>
            <StyledButton>
                {text}
            </StyledButton>
        </div>
    );
}

export default Button;