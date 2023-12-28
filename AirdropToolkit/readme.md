# ERC-20 Airdrop Toolkit

This repository contains the necessary code and instructions to do an token airdrop distribution using a solidity smart contract and a merkle tree.

This airdrop system is designed to allow users to claim tokens by submitting a merkle proof along their ethereum address and the allocation amount.

## Components

1. **Airdrop Contract (Solidity)**: A smart contract that enables users to claim their tokens by providing a merkle proof.
2. **Merkle Tree Generator (Python)**: A script to generate a Merkle tree from a list of {address: amount} pairs, compute the merkle root and generate a proof for a specific address.

## Setup and Installation

### A. Solidity Contract

1. **Prerequisites**:
   - Install [Node.js and npm](https://nodejs.org/).
   - Install Hardhat, Truffle or Foundry for testing and deployment (optional).
   - Python 3.x
   - MerkleTools and Crypto.Hash python libraries
   - A web3 wallet to interact with the smart contract.

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
- Use the Python merkle tree script to generate the Merkle root.
- Update the merkle root in the Solidity contract.

### Step 2: Airdrop Claim

- Users can claim their tokens through the smart contract by providing a valid merkle proof.
- Ensure that the user's address is part of the merkle tree and has not claimed the tokens before.

## Security Considerations

- Solidity code in this repo has not been audited by a third-party.
- The merkle root should be set by a trusted party to prevent fraudulent claims.

## Contributing

Contributions to the project are welcome. Please ensure that any pull requests or issues adhere to the project's guidelines.

## License

No license whatsoever, anyone can freely modify and deploy this code.
