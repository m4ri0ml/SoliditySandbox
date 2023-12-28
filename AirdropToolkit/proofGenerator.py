
from Crypto.Hash import keccak

def keccak_hash(data):
    k = keccak.new(digest_bits=256)
    k.update(data.encode())
    return k.hexdigest()

def generate_merkle_proof(mt, address, amount):
    leaf_node = keccak_hash(f'{address.lower()}{amount}')
    proof = mt.get_proof(mt.get_leaf_index(leaf_node))
    return [p['right'] if 'right' in p else p['left'] for p in proof]

# Example usage for generating a proof
address = '0x000158E60C393B51fdFAc71B14Ce70b70148C326'
amount = 100
root = '0837440382c2c3301fbffa3abc8a50e2883c0c009b30ff48498152d49fb2656a'

proof = generate_merkle_proof(root, address, amount)
print(f'Proof for {address}: {proof}')
