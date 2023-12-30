// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/IERC20.sol";
import "../utils/MerkleProof.sol";
import "../utils/Owned.sol";

contract TokenDistributor is Owned {
    IERC20 public airdropToken;
    bytes32 public merkleRoot;
    uint256 nonce;

    mapping(address => bool) public blacklisted;
    mapping(address => bool) public claimed;

    event Claimed(address indexed claimant, uint256 amount);

    constructor() Owned(msg.sender) {}

    function submitProofAndClaim(uint256 amount, bytes32[] calldata proof) external {
        require(!claimed[msg.sender], "Airdrop already claimed.");
        require(!blacklisted[msg.sender], "User is blacklisted");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof.");

        claimed[msg.sender] = true;
        airdropToken.transfer(msg.sender, amount);
        nonce += 1;

        emit Claimed(msg.sender, amount);
    }

    /*
    
    This is a iteration of the function above where users only need to submit a merkle proof,
    which means they can claim the airdrop without knowing their allocated amount but its *very*
    gas intensive as it iteratives over every amount from the minimum to the maximum one
    until they find the correct allocation for the user and the proof is validated.

    function submitProofAndClaim(bytes32[] calldata proof) external {
        require(!claimed[msg.sender], "Airdrop already claimed.");

        uint256 airdropMinAlloc;
        uint256 airdropMaxAlloc;

        uint256 userAlloc;
        bool validProof = false;

        for (userAlloc = airdropMinAlloc; userAlloc <= airdropMaxAlloc; userAlloc++) {
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender, userAlloc));
            if (MerkleProof.verify(proof, merkleRoot, leaf)) {
                validProof = true;
                break;
            }
        }

        require(validProof, "Invalid proof");
        claimed[msg.sender] = true;
        airdropToken.transfer(msg.sender, userAlloc);

        emit Claimed(msg.sender, userAlloc);
    }

    */

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setAirdropToken(address _token) external onlyOwner {
        airdropToken = IERC20(_token);
    }

    function blacklistAddress(address _user) external onlyOwner {
        blacklisted[_user] = true;
    }
}
