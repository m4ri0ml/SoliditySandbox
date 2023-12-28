# Airdrop Contract and Merkle Tree Generation

This repository contains the necessary code and instructions for setting up an airdrop using a Solidity smart contract and a Merkle tree for efficient and secure distribution of tokens.

## Overview

The airdrop system is designed to allow users to claim tokens allocated to them in an airdrop. It uses a Solidity-based smart contract for the airdrop and a Python script to generate a Merkle tree.

## Components

1. **Airdrop Contract (Solidity)**: A smart contract that enables users to claim their tokens by providing a Merkle proof.
2. **Merkle Tree Generator (Python)**: A script to generate a Merkle tree from a list of {address: amount} pairs and compute the Merkle root.

## Setup and Installation

### A. Solidity Contract

1. **Prerequisites**:
   - Install [Node.js and npm](https://nodejs.org/).
   - Install [Truffle Suite](https://www.trufflesuite.com/) for testing and deployment (optional).
   - [MetaMask](https://metamask.io/) for interacting with the Ethereum blockchain.

2. **Deployment**:
   - Use [Remix IDE](https://remix.ethereum.org/) to compile and deploy the contract.
   - Set the ERC20 token address and deploy the contract on the desired network (e.g., Rinkeby testnet).

### B. Merkle Tree Generator (Python)

1. **Prerequisites**:
   - Python 3.x installed.
   - Install `merkletools` using pip: `pip install merkletools`.

2. **Usage**:
   - Run the Python script with the list of {address: amount} pairs to generate the Merkle tree and obtain the Merkle root.

## Usage Guide

### Step 1: Generating Merkle Tree

- Prepare a list of addresses and their respective token amounts in a JSON or Python dictionary format.
- Use the Python Merkle tree script to generate the Merkle root.
- Update the Merkle root in the Solidity contract.

### Step 2: Airdrop Claim

- Users can claim their tokens through the smart contract by providing a valid Merkle proof.
- Ensure that the user's address is part of the Merkle tree and has not claimed the tokens before.

## Security Considerations

- Ensure that the contract is tested thoroughly before deployment.
- The Merkle root should be set by a trusted party to prevent fraudulent claims.

## Contributing

Contributions to the project are welcome. Please ensure that any pull requests or issues adhere to the project's guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
