// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/IERC20.sol";
import "../utils/MerkleProof.sol";
import "../utils/Owned.sol";

contract TokenDistributor is Owned {
    IERC20 public token;
    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;

    event Claimed(address indexed claimant, uint256 amount);

    constructor(address tokenAddress) Owned(msg.sender) {
        token = IERC20(tokenAddress);
    }

    function setMerkleRoot(bytes32 _merkleRoot) external {
        // TODO: Add onlyOwner modifier or equivalent access control
        merkleRoot = _merkleRoot;
    }

    function submitProofAndClaim(uint256 amount, bytes32[] calldata proof) external {
        require(!claimed[msg.sender], "Airdrop already claimed.");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof.");

        claimed[msg.sender] = true;
        require(token.transfer(msg.sender, amount), "Transfer failed.");

        emit Claimed(msg.sender, amount);
    }
}
