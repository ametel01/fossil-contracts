#[starknet::interface]
trait IFossilAccess<TContractState> {
    fn freeze_all(ref self: TContractState);
    fn unfreeze_all(ref self: TContractState);
}

#[starknet::component]
mod FossilAccessComponent {
    use openzeppelin_access::accesscontrol::interface::IAccessControl;
    use openzeppelin_access::accesscontrol::{
        AccessControlComponent, AccessControlComponent::AccessControlImpl
    };
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_upgrades::upgradeable::UpgradeableComponent;
    use starknet::contract_address_const;

    pub const TIMELOCK_ROLE: felt252 =
        0x5f7316d60cf1f828ab97f367a66060cc70af5e656dcaa8607039c5a80c791ea; // TIMELOCK_ROLE

    pub const GUARDIAN_ROLE: felt252 =
        0x6715d023274fcce1c9eb8293e5782731940947d233a8d490a86c3961e67b1b6; // GUARDIAN_ROLE

    pub const UNFREEZE_ROLE: felt252 =
        0x3ee6bb1c90037ebf80241cbdab0644540e8558e9974b52e9be9d186cb1d009b; //UNFREEZE_ROLE

    pub const PROVER_ROLE: felt252 =
        0x45abebbd5d354a9c1c579a487471faca25a4023e8234ea423752df8fadf92ad; // PROVER_ROLE

    pub const AXIOM_ROLE: felt252 =
        0x21a35a69d83f5207aed234a30d978cfda3d20aa30ec31cfdeeea14bb0baa816; // FOSSIL_ROLE

    #[storage]
    struct Storage {
        frozen: bool
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        FreezeAll: FreezeAll,
        UnfreezeAll: UnfreezeAll,
    }

    #[derive(Drop, starknet::Event)]
    struct FreezeAll {}

    #[derive(Drop, starknet::Event)]
    struct UnfreezeAll {}

    mod Errors {
        pub const CONTRACT_IS_FROZEN: felt252 = 'Contract is frozen';
        pub const NOT_PROVER_ROLE: felt252 = 'Not prover role';
        pub const NOT_FOSSIL_ROLE: felt252 = 'Not Fossil role';
    }

    #[abi(embed_v0)]
    impl FossilAccesImpl<
        TContractState,
        +HasComponent<TContractState>,
        +AccessControlComponent::HasComponent<TContractState>,
        +UpgradeableComponent::HasComponent<TContractState>
    > of super::IFossilAccess<ComponentState<TContractState>> {
        fn freeze_all(ref self: ComponentState<TContractState>) {
            self.frozen.write(true);
            self.emit(FreezeAll {});
        }

        fn unfreeze_all(ref self: ComponentState<TContractState>) {
            self.frozen.write(false);
            self.emit(UnfreezeAll {});
        }
    }

    #[generate_trait]
    impl Private<
        TContractState,
        +HasComponent<TContractState>,
        impl Access: AccessControlComponent::HasComponent<TContractState>,
        +UpgradeableComponent::HasComponent<TContractState>,
        +SRC5Component::HasComponent<TContractState>,
        +Drop<TContractState>
    > of PrivateTrait<TContractState> {
        fn only_prover(ref self: ComponentState<TContractState>) {
            self._check_prover();
        }

        fn only_not_frozen(ref self: ComponentState<TContractState>) {
            self._check_not_frozen();
        }

        fn _check_prover(self: @ComponentState<TContractState>) {
            let access_component = get_dep_component!(self, Access);
            if (!(access_component.has_role(PROVER_ROLE, contract_address_const::<0>()))
                || access_component.has_role(PROVER_ROLE, starknet::get_caller_address())) {
                panic!("{}", Errors::NOT_PROVER_ROLE);
            };
        }

        fn _check_not_frozen(ref self: ComponentState<TContractState>) {
            if self.frozen.read() {
                panic!("{}", Errors::CONTRACT_IS_FROZEN);
            };
        }

        fn _fossil_access_init(ref self: ComponentState<TContractState>) {
            self._fossil_access_init_unchained();
        }

        fn _fossil_access_init_unchained(ref self: ComponentState<TContractState>) {
            self.frozen.write(false);
        }
    }
}
