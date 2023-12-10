import React, { CSSProperties, useState } from 'react';
import Grid from '@mui/material/Unstable_Grid2';
import { Stack } from '@mui/material';
import { useAccount, useContractReads } from 'wagmi';
import "./scrollbar.css";
import axios from "axios";
import { useQuery } from "react-query";
import LinkieStats from '../interfaces/linkie-stats';

function QueryOwnedLinkieIds(address: string | undefined) {
    const query = `{
        tokens(where: {owner: "` + address + `"}) {
            tokenId
        }
    }`;
    
    const { data } = useQuery("launches", async () => {
        const response = await axios({
            url: "https://api.thegraph.com/subgraphs/name/paranoidsyntaxerror/linkie",
            method: "POST",
            data: {
                query: query
            }
        });

        return response.data.data;
    });

    let tokenIds: BigInt[] = [];
    for(let i = 0; i < data?.tokens.length; i++) {
        tokenIds.push(data?.tokens[i].tokenId);
    }

    return tokenIds;
}

function QueryLinkieStats(tokenIds: BigInt[]) {
    let contractReads: any = [];
    for(let i = 0; i < tokenIds.length; i++) {
        contractReads.push({
            address: "0xbD4d23c124B697C2494F4546f356453D907A4056",
            abi: [{
                "inputs": [
                    {
                    "internalType": "uint256",
                    "name": "id",
                    "type": "uint256"
                    }
                ],
                "name": "stats",
                "outputs": [
                    {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                    },
                    {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                    },
                    {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                    },
                    {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                    },
                    {
                    "internalType": "bool",
                    "name": "",
                    "type": "bool"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            }],
            functionName: "stats",
            args: [tokenIds[i]]
        });
    }

    const { data } = useContractReads({ contracts: contractReads });

    let stats: LinkieStats[] = [];
    if(data?.length != undefined) {
        for(let i = 0; i < data.length; i++) {
            const results = data[i].result as any[];
            stats.push({
                tokenId: tokenIds[i] as bigint,
                lifeCycle: results[0] as bigint,  
                species: results[1] as bigint,  
                hunger: results[2] as bigint,  
                sickness: results[3] as bigint,
                alive: results[4] as boolean
            });
        }
    }

    return stats;
}

export default function LinkieList() {  
    const rootStyle: CSSProperties = {
        backgroundColor: "rgba(255, 255, 255, 0.5)",
        borderRadius: "1rem",
        border: "0.5rem solid pink",
        width: "11rem",
        height: "70vh"
    };

    const cardStyle = (tokenId: BigInt) => {
        let style: CSSProperties = {
            width: "7rem",
            height: "fit-content",
            backgroundColor: "deeppink",
            color: "white",
            padding: "0.5rem",
            borderRadius: "0.5rem",
            cursor: "pointer",
            border: "black solid 0.25rem"
        };
        
        if(selectedLinkie?.tokenId == tokenId) {
            style.backgroundColor = "cyan";
            style.color = "black";
        }

        return style;
    };

    const imgStyle: CSSProperties = {
        width: "100%",
        borderRadius: "0.5rem",
        backgroundColor: "pink"
    };

    const textStyle: CSSProperties = {
        fontFamily: "monospace",
        fontSize: "1rem",
    };

    const [ selectedLinkie, setSelectedLinkie ] = useState<LinkieStats | undefined>(undefined);

    const { address } = useAccount();
    const ownedLinkieIds = QueryOwnedLinkieIds(address?.toString());
    const linkieStats = QueryLinkieStats(ownedLinkieIds);

    if(selectedLinkie == undefined && linkieStats?.length > 0) {
        setSelectedLinkie(linkieStats[0]);
    }

    const cards = () => {
        if(linkieStats != undefined && ownedLinkieIds != undefined && linkieStats.length > 0) {
            return (
                ownedLinkieIds?.map((tokenId: BigInt, index: number) => (
                    <div style={cardStyle(tokenId)} onClick={() => (setSelectedLinkie(linkieStats[index]))} key={index}>
                        <img src={linkieStats[index].lifeCycle + "_" + linkieStats[index].species + ".png"} style={imgStyle}></img>
                        <div style={textStyle}>
                            Linkie #{tokenId.toString()}
                        </div>
                    </div>         
                ))
            );
        }
    };

    return {
        view: <div style={rootStyle}>
            <Stack margin="1rem 0" rowGap="1rem" columnGap="1rem" alignItems="center" sx={{
                width: "100%",
                height: "100%",
                overflowY: "scroll",
            }}>
                {cards()}
            </Stack>
        </div>,
        selectedLinkie: selectedLinkie
    };
}