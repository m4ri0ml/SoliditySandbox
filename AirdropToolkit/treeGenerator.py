from web3 import Web3

# This script generates a merkle tree with the input data and  
# generates the proof for a leaf of the merkle tree needed in
# the submitProofAndClaim() function found in TokenDistributor.sol

class MerkleTree:
    def __init__(self, leaves):
        self.leaves = leaves
        self.tree = []
        self.create_tree()
    
    # We make sure the hash from this script and the one generated with Solidity are the same
    # by using the same hash function.
    def solidity_keccak(address, amount):
        address_bytes = Web3.toBytes(hexstr=address)
        amount_bytes = amount.to_bytes(32, byteorder='big')
        return Web3.keccak(address_bytes + amount_bytes)

    def create_tree(self):
        tree_level = self.leaves
        self.tree.append(tree_level)
        while len(tree_level) > 1:
            tree_level = self.get_next_tree_level(tree_level)
            self.tree.append(tree_level)

    def get_next_tree_level(self, current_level):
        next_level = []
        for i in range(0, len(current_level), 2):
            left = current_level[i]
            right = current_level[i + 1] if i + 1 < len(current_level) else left
            next_level.append(Web3.keccak(left + right))
        return next_level

    def get_root(self):
        return self.tree[-1][0]

    def get_proof(self, leaf):
        proof = []
        index = self.leaves.index(leaf)
        for level in self.tree[:-1]:
            if index % 2 == 0:
                pair_index = index + 1 if index + 1 < len(level) else index
            else:
                pair_index = index - 1
            proof.append(level[pair_index].hex())
            index = index // 2
        return proof

# JSON file recommended for large distributions.
data = {
    'address1': 100,
    'address2': 200,
    'address3': 300
}

leaf_nodes = [MerkleTree.solidity_keccak(address, amount) for address, amount in data.items()]
merkle_tree = MerkleTree(leaf_nodes)
merkle_root = merkle_tree.get_root()

print("Merkle Root:", merkle_root.hex())

# Generate proof for a specific leaf
proof_address = 'address1'
proof_amount = 300
proof_leaf = MerkleTree.solidity_keccak(proof_address, proof_amount)
proof = merkle_tree.get_proof(proof_leaf)

print(f"Proof for {proof_address}:", proof)
