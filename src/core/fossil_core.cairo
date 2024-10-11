#[starknet::contract]
mod FossilCore {
    use fossil::core::interface::IFossilCore;
    use starknet::{ContractAddress, contract_address_const};
    use starknet::storage::Map;
    use fossil::libraries::padded_merkle_mountain_range::PMMR;
    use fossil::libraries::merkle_mountain_range::MMR;
    use fossil::interfaces::ifossil_verifier::BlockHashWitness;

    #[storage]
    struct Storage {
        verifier_address: ContractAddress,
        historical_verifier_address: ContractAddress,
        historical_roots: Map<usize, felt252>,
        blockhash_pmmr: PMMR,
        pmmr_snapshots: Map<usize, felt252>,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        verifier_address: ContractAddress,
        historical_verifier_address: ContractAddress,
        timelock: ContractAddress,
        guardian: ContractAddress,
        unfreeze: ContractAddress,
        prover: ContractAddress
    ) {
        assert!(verifier_address != contract_address_const::<0>());
        assert!(historical_verifier_address != contract_address_const::<0>());
        assert!(timelock != contract_address_const::<0>());
        assert!(guardian != contract_address_const::<0>());
        assert!(unfreeze != contract_address_const::<0>());
        assert!(prover != contract_address_const::<0>());
    }

    #[abi(embed_v0)]
    impl FossilCoreImpl of IFossilCore<ContractState> {
        fn update_recent(ref self: ContractState, proof_data: Span<felt252>) {}
        fn update_old(
            ref self: ContractState,
            next_root: felt252,
            next_num_final: usize,
            proof_data: Span<felt252>
        ) {}
        fn update_historical(
            ref self: ContractState,
            next_root: felt252,
            next_num_final: usize,
            roots: Span<felt252>,
            end_hash_proofs: Span<Span<felt252>>,
            proof_data: Span<felt252>
        ) {}
        fn append_historical_PMMR(
            ref self: ContractState,
            roots: Span<felt252>,
            prev_hashes: Span<felt252>,
            last_num_final: usize
        ) {}
        fn upgrade_snark_verifier(ref self: ContractState, new_verifier: ContractAddress) {}
        fn upgrade_historical_snark_verifier(
            ref self: ContractState, new_verifier: ContractAddress
        ) {}
        fn block_hash_pmmr_leaf(self: @ContractState) -> felt252 {
            0
        }
        fn block_hash_pmmr_peaks(self: @ContractState, index: usize) -> MMR {
            Default::default()
        }
        fn block_hash_pmmr_size(self: @ContractState) -> usize {
            0
        }
        fn full_block_hash_pmmr(self: @ContractState, index: usize) -> PMMR {
            Default::default()
        }
        fn is_recent_block_hash_valid(
            self: @ContractState, block_number: u64, claimed_block_hash: u256
        ) -> bool {
            true
        }
        fn is_block_hash_valid(self: @ContractState, witness: BlockHashWitness) -> bool {
            true
        }
    }
}
