import { Address, BigInt, Bytes } from "@graphprotocol/graph-ts"
import { Transfer as TransferEvent } from "../generated/LinkieCCIP/LinkieCCIP"
import { Token, Owner } from "../generated/schema"

export function handleTransfer(event: TransferEvent): void {
  let tokenEntityId = Bytes.fromByteArray(Bytes.fromBigInt(event.params.tokenId));
  let token = Token.load(tokenEntityId);

  if(token == null) {
    token = new Token(tokenEntityId);
    token.tokenId = event.params.tokenId;
  }
  token.owner = event.params.to;
  
  let newOwner = Owner.load(event.params.to);
  if(newOwner == null) {
    newOwner = new Owner(event.params.to);
    newOwner.balance = BigInt.fromU32(1);
  } else {
    newOwner.balance = newOwner.balance.plus(BigInt.fromU32(1));
  }

  if(event.params.from != Address.zero()) {
    let previousOwner = Owner.load(event.params.from);
    if(previousOwner == null) {
      previousOwner = new Owner(event.params.from);
      newOwner.balance = BigInt.fromU32(0);
    } else {
      previousOwner.balance = previousOwner.balance.minus(BigInt.fromU32(1));
    }
    previousOwner.save();
  }

  token.save();
  newOwner.save();
}