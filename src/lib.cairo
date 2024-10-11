mod core {
    mod fossil_core;
    pub mod interface;
}
pub mod libraries {
    pub mod configuration;
    pub mod merkle_mountain_range;
    pub mod padded_merkle_mountain_range;
    pub mod access {
        pub mod fossil_access;
    }
}
pub mod interfaces {
    pub mod ifossil_verifier;
}
