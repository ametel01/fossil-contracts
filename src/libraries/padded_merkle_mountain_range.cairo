use fossil::libraries::merkle_mountain_range::MMR;

#[derive(Drop, Serde)]
pub struct PMMR {
    complete_leaves: MMR,
    padded_leaf: felt252,
    size: usize,
}
