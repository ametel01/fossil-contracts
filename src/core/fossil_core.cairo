#[starknet::contract]
mod FossilCore {
    use openzeppelin_access::accesscontrol::interface::IAccessControl;
    use fossil::core::interface::IFossilCore;
    use starknet::{ContractAddress, contract_address_const};
    use starknet::storage::Map;
    use fossil::libraries::padded_merkle_mountain_range::PMMR;
    use fossil::libraries::merkle_mountain_range::MMR;
    use fossil::interfaces::ifossil_verifier::BlockHashWitness;
    use fossil::libraries::access::fossil_access::FossilAccessComponent;
    use openzeppelin_access::accesscontrol::accesscontrol::AccessControlComponent;
    use openzeppelin_upgrades::upgradeable::UpgradeableComponent;
    use openzeppelin_upgrades::interface::IUpgradeable;
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_access::ownable::OwnableComponent;

    component!(path: FossilAccessComponent, storage: fossilaccess, event: FossilAccessEvent);
    component!(path: AccessControlComponent, storage: accesscontrol, event: AccessControlEvent);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl FossilAccessImpl = FossilAccessComponent::FossilAccessImpl<ContractState>;
    impl FossilAccessPrivateImpl = FossilAccessComponent::PrivateImpl<ContractState>;
    #[abi(embed_v0)]
    impl AccessControlImpl =
        AccessControlComponent::AccessControlImpl<ContractState>;
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    mod Errors {
        pub fn verifier_address_is_zero() {
            panic!("Verifier address is zero");
        }
        pub fn historical_verifier_address_is_zero() {
            panic!("Historical verifier address is zero");
        }
        pub fn timelock_address_is_zero() {
            panic!("Timelock address is zero");
        }
        pub fn guardian_address_is_zero() {
            panic!("Guardian address is zero");
        }
        pub fn unfreeze_address_is_zero() {
            panic!("Unfreeze address is zero");
        }
        pub fn prover_address_is_zero() {
            panic!("Prover address is zero");
        }
        pub fn owner_address_is_zero() {
            panic!("Owner address is zero");
        }
    }

    #[storage]
    struct Storage {
        verifier_address: ContractAddress,
        historical_verifier_address: ContractAddress,
        historical_roots: Map<usize, felt252>,
        blockhash_pmmr: PMMR,
        pmmr_snapshots: Map<usize, felt252>,
        #[substorage(v0)]
        fossilaccess: FossilAccessComponent::Storage,
        #[substorage(v0)]
        accesscontrol: AccessControlComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        UpgradeSnarkVerifier: UpgradeSnarkVerifier,
        UpgradeHistoricalSnarkVerifier: UpgradeHistoricalSnarkVerifier,
        #[flat]
        FossilAccessEvent: FossilAccessComponent::Event,
        #[flat]
        AccessControlEvent: AccessControlComponent::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    #[derive(Drop, starknet::Event)]
    struct UpgradeSnarkVerifier {
        new_verifier: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct UpgradeHistoricalSnarkVerifier {
        new_verifier: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        verifier_address: ContractAddress,
        historical_verifier_address: ContractAddress,
        timelock: ContractAddress,
        guardian: ContractAddress,
        unfreeze: ContractAddress,
        prover: ContractAddress,
        owner: ContractAddress
    ) {
        self
            .initialize(
                verifier_address,
                historical_verifier_address,
                timelock,
                guardian,
                unfreeze,
                prover,
                owner
            );
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

    #[abi(embed_v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: starknet::ClassHash) {
            self.upgradeable.upgrade(new_class_hash);
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn initialize(
            ref self: ContractState,
            verifier_address: ContractAddress,
            historical_verifier_address: ContractAddress,
            timelock: ContractAddress,
            guardian: ContractAddress,
            unfreeze: ContractAddress,
            prover: ContractAddress,
            owner: ContractAddress
        ) {
            if verifier_address == contract_address_const::<0>() {
                Errors::verifier_address_is_zero();
            }
            if historical_verifier_address == contract_address_const::<0>() {
                Errors::historical_verifier_address_is_zero();
            }
            if timelock == contract_address_const::<0>() {
                Errors::timelock_address_is_zero();
            }
            if guardian == contract_address_const::<0>() {
                Errors::guardian_address_is_zero();
            }
            if unfreeze == contract_address_const::<0>() {
                Errors::unfreeze_address_is_zero();
            }
            if prover == contract_address_const::<0>() {
                Errors::prover_address_is_zero();
            }
            if owner == contract_address_const::<0>() {
                Errors::owner_address_is_zero();
            }

            self.ownable.initializer(owner);
            self.fossilaccess._fossil_access_init_unchained();

            self.verifier_address.write(verifier_address);
            self.historical_verifier_address.write(historical_verifier_address);
            self.emit(UpgradeSnarkVerifier { new_verifier: verifier_address });
            self.emit(UpgradeHistoricalSnarkVerifier { new_verifier: historical_verifier_address });

            self.accesscontrol.grant_role(FossilAccessComponent::DEFAULT_ADMIN_ROLE, timelock);
            self.accesscontrol.grant_role(FossilAccessComponent::TIMELOCK_ROLE, timelock);
            self.accesscontrol.grant_role(FossilAccessComponent::PROVER_ROLE, prover);
            self.accesscontrol.grant_role(FossilAccessComponent::GUARDIAN_ROLE, guardian);
            self.accesscontrol.grant_role(FossilAccessComponent::UNFREEZE_ROLE, unfreeze);
        }
    }
}
