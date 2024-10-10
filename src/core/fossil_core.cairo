use starknet::ContractAddress;
use fossil::libraries::merkle_mountain_range::MMR;
use fossil::libraries::padded_merkle_mountain_range::PMMR;
use fossil::interfaces::ifossil_verifier::BlockHashWitness;
#[starknet::interface]
pub trait FossilCore<TState> {
    fn initialize(
        ref self: TState,
        verifier_address: ContractAddress,
        historical_verifier_address: ContractAddress,
        timelock: ContractAddress,
        guardian: ContractAddress,
        unfreeze: ContractAddress,
        prover: ContractAddress
    );
    fn update_recent(ref self: TState, proof_data: Span<felt252>);
    fn update_old(
        ref self: TState, next_root: felt252, next_num_final: usize, proof_data: Span<felt252>
    );
    fn update_historical(
        ref self: TState,
        next_root: felt252,
        next_num_final: usize,
        roots: Span<felt252>,
        end_hash_proofs: Span<Span<felt252>>,
        proof_data: Span<felt252>
    );
    fn append_historical_PMMR(
        ref self: TState, roots: Span<felt252>, prev_hashes: Span<felt252>, last_num_final: usize
    );
    fn upgrade_snark_verifier(ref self: TState, new_verifier: ContractAddress);
    fn upgrade_historical_snark_verifier(ref self: TState, new_verifier: ContractAddress);
    fn block_hash_pmmr_leaf(self: @TState) -> felt252;
    fn block_hash_pmmr_peaks(self: @TState, index: usize) -> MMR;
    fn block_hash_pmmr_size(self: @TState) -> usize;
    fn full_block_hash_pmmr(self: @TState, index: usize) -> PMMR;
    fn is_recent_block_hash_valid(
        self: @TState, block_number: u64, claimed_block_hash: u256
    ) -> bool;
    fn is_block_hash_valid(self: @TState, witness: BlockHashWitness) -> bool;
}
