from merkletools import MerkleTools
from Crypto.Hash import keccak

# Instead of SHA-256 hash function we use Keccak to ensure compatibility with Solidity.
def keccak_hash(data):
    k = keccak.new(digest_bits=256)
    k.update(data.encode())
    return k.hexdigest()

# Tree Generation Functions

def generate_merkle_tree(data):
    mt = MerkleTools()
    for address, amount in data.items():
        leaf_node = keccak_hash(f'{address.lower()}{amount}')
        mt.add_leaf(leaf_node)
    mt.make_tree()
    return mt

# Proof Generation Functions

def find_leaf_index(mt, leaf_node):
    for index in range(mt.get_leaf_count()):
        if mt.get_leaf(index) == leaf_node:
            return index
    return None

def generate_merkle_proof(mt, address, amount):
    leaf_node = keccak_hash(f'{address.lower()}{amount}')
    index = find_leaf_index(mt, leaf_node)
    if index is not None:
        return mt.get_proof(index)
    return None

# Example usage - Better to use a json file for big distributions.
data = {
    'address_1': 100,
    'address_2': 200,
    # ... more addresses
}

# Generate the Merkle tree
merkle_tree = generate_merkle_tree(data)

# Specify the address and amount for which you want to generate the proof
specific_address = ''
specific_amount = 200

# Generate the proof
proof = generate_merkle_proof(merkle_tree, specific_address, specific_amount)

# Output the proof
if proof is not None:
    print(f'Proof for {specific_address}: {proof}')
else:
    print(f'No proof found for {specific_address} with amount {specific_amount}')
