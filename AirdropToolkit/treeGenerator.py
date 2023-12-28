from merkletools import MerkleTools
from Crypto.Hash import keccak

def keccak_hash(data):
    k = keccak.new(digest_bits=256)
    k.update(data.encode())
    return k.hexdigest()

def generate_merkle_tree(data):
    mt = MerkleTools()  # Default hash type (SHA256)
    for address, amount in data.items():
        leaf_node = keccak_hash(f'{address.lower()}{amount}')
        mt.add_leaf(leaf_node)
    mt.make_tree()
    return mt

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

# Example usage
data = {
    '0x000158E60C393B51fdFAc71B14Ce70b70148C326': 100,
    '0x9a285D90b567cEa64dD82737340E224Fd4202959': 200,
    # ... more addresses
}

# Generate the Merkle tree
merkle_tree = generate_merkle_tree(data)

# Specify the address and amount for which you want to generate the proof
specific_address = '0x9a285D90b567cEa64dD82737340E224Fd4202959'
specific_amount = 200

# Generate the proof
proof = generate_merkle_proof(merkle_tree, specific_address, specific_amount)

# Output the proof
if proof is not None:
    print(f'Proof for {specific_address}: {proof}')
else:
    print(f'No proof found for {specific_address} with amount {specific_amount}')
