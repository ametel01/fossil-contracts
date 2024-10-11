const MAX_MMR_PEAKS: usize = 32;

#[derive(Default, Drop, Serde, starknet::Store)]
pub struct MMR {
    peaks: Peaks,
    peaks_length: usize,
}

#[derive(Default, Drop, Serde, starknet::Store)]
struct Peaks {
    p0: felt252,
    p1: felt252,
    p2: felt252,
    p3: felt252,
    p4: felt252,
    p5: felt252,
    p6: felt252,
    p7: felt252,
    p8: felt252,
    p9: felt252,
    p10: felt252,
    p11: felt252,
    p12: felt252,
    p13: felt252,
    p14: felt252,
    p15: felt252,
    p16: felt252,
    p17: felt252,
    p18: felt252,
    p19: felt252,
    p20: felt252,
    p21: felt252,
    p22: felt252,
    p23: felt252,
    p24: felt252,
    p25: felt252,
    p26: felt252,
    p27: felt252,
    p28: felt252,
    p29: felt252,
    p30: felt252,
    p31: felt252,
}
