use fossil::libraries::merkle_mountain_range::MMR;

#[derive(Default, Drop, Serde, starknet::Store)]
pub struct PMMR {
    complete_leaves: MMR,
    padded_leaf: felt252,
    size: usize,
}
