#[derive(Drop, Serde)]
pub struct BlockHashWitness {
    block_number: u32,
    claimed_block_hash: felt252,
    prev_hash: felt252,
    num_final: u32,
    merkle_proof: Span<felt252>,
}
