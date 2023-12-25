# smolMarketplace

## Introduction

This contract leverages the power of smart contracts to facilitate a marketplace for trading Non-Fungible Tokens (NFTs). It allows users to list their NFTs, place and manage bids, and execute sales in a decentralized environment.

## Description

This is a singleton contract built with Solidity that conforms to the ERC721 standard, ensuring compatibility with a wide range of NFTs. It's designed to be both user-friendly and robust, providing features that cater to both NFT owners and potential buyers. From depositing NFTs to bidding and finalizing sales.

Code is free and open source software (FOSS). Anyone has the right to deploy or modify the contract in any way they WANT. No rights are reserved  by the auther (0xM4R10).

## Features

### NFT Deposit

Users can deposit their NFTs into the contract for listing in the marketplace. Each NFT deposit records essential details such as the depositor's address, collection address, token ID, minimum price, and sale status.

- **Function**: `depositNFT(collection, tokenId)`
- **Purpose**: Deposit an NFT into the marketplace for sale or auction.
- **Parameters**:
  - `collection`: The address of the NFT collection.
  - `tokenId`: The token ID of the NFT.

### Bidding

Bidders can place bids on listed NFTs. Each bid is linked to the specific NFT and bidder, ensuring a transparent and efficient bidding process.

- **Function**: `placeBid(collection, tokenId, amount, deadline)`
- **Purpose**: Place a bid on a specific NFT.
- **Parameters**:
  - `collection`: The address of the NFT collection.
  - `tokenId`: The token ID of the NFT.
  - `amount`: The amount of the bid.
  - `deadline`: The deadline for the bid.

### Accepting Bids

NFT owners can accept bids for their NFTs. Accepting a bid will transfer the NFT to the bidder and handle the transfer of funds.

- **Function**: `acceptBid(collection, tokenId, bidId)`
- **Purpose**: Accept a specific bid for an NFT.
- **Parameters**:
  - `collection`: The address of the NFT collection.
  - `tokenId`: The token ID of the NFT.
  - `bidId`: The unique identifier of the bid.

### Cancelling Bids

Bidders have the option to cancel their bids under certain conditions, ensuring flexibility and control over their bidding strategy.

- **Function**: `cancelBid(collection, tokenId)`
- **Purpose**: Cancel a previously placed bid.
- **Parameters**:
  - `collection`: The address of the NFT collection.
  - `tokenId`: The token ID of the NFT.

### Marketplace Fee

- Contract implements a variable fee that is charged to the seller when someone buys a listed NFT.

### To-Do / Ideas
- **Multi-token**: Accept multiple ERC20 tokens as payments (Only WETH supported right now)
- **Decaying bids**: Make a type of bid that decreases its offer as time passes.
- **NFT Auctions**: Allow sellers to auction their NFT
- **NFT Rentals**: Allow owners to rent their NFT for a fee.

## Security Considerations

- smolMarketplace has NOT being audited by a third-party.
- Anyone using this contract in production should perform an extensive security review on the code

---
