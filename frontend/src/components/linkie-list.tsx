import React, { CSSProperties, useState } from 'react';
import Grid from '@mui/material/Unstable_Grid2';
import { Stack } from '@mui/material';
import { useAccount, useContractReads } from 'wagmi';
import "./scrollbar.css";
import axios from "axios";
import { useQuery } from "react-query";
import LinkieStats from '../interfaces/linkie-stats';

interface SubgraphToken {
    tokenId: bigint,
    network: string
}

function QueryOwnedTokens(address: string | undefined) {
    const query = `{
        tokens(where: {owner: "` + address + `"}) {
            tokenId,
            network
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

    let tokens: SubgraphToken[] = [];
    for(let i = 0; i < data?.tokens.length; i++) {
        tokens.push({tokenId: data?.tokens[i].tokenId, network: data?.tokens[i].network});
    }

    return tokens;
}

function QueryLinkieStats(tokens: SubgraphToken[]) {
    let contractReads: any = [];
    for(let i = 0; i < tokens.length; i++) {
        contractReads.push({
            address: "0x3D2B691B2F2FcC96f693957bE27ED7809fC912a7",
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
            args: [tokens[i].tokenId]
        });
    }

    const { data } = useContractReads({ contracts: contractReads });

    let stats: LinkieStats[] = [];
    if(data?.length != undefined) {
        for(let i = 0; i < data.length; i++) {
            const results = data[i].result as any[];
            stats.push({
                tokenId: tokens[i].tokenId as bigint,
                lifeCycle: results[0] as bigint,  
                species: results[1] as bigint,  
                hunger: results[2] as bigint,  
                sickness: results[3] as bigint,
                alive: results[4] as boolean,
                network: tokens[i].network as string
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
            border: "black solid 0.25rem",
            margin: "0.5rem 0"
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
    const ownedTokens = QueryOwnedTokens(address?.toString());
    const linkieStats = QueryLinkieStats(ownedTokens);

    if(selectedLinkie == undefined && linkieStats?.length > 0) {
        setSelectedLinkie(linkieStats[0]);
    }

    const cards = () => {
        if(linkieStats != undefined && ownedTokens != undefined && linkieStats.length > 0) {
            return (
                ownedTokens?.map((token: SubgraphToken, index: number) => (
                    <div style={cardStyle(token.tokenId)} onClick={() => (setSelectedLinkie(linkieStats[index]))} key={index}>
                        <img src={linkieStats[index].lifeCycle + "_" + linkieStats[index].species + ".png"} style={imgStyle}></img>
                        <div style={textStyle}>
                            Linkie #{token.tokenId.toString()}
                        </div>
                    </div>         
                ))
            );
        }
    };

    return {
        view: <div style={rootStyle}>
            <Stack columnGap="1rem" alignItems="center" sx={{
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