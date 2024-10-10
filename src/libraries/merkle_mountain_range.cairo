const MAX_MMR_PEAKS: usize = 32;

#[derive(Drop, Serde)]
pub struct MMR {
    peaks: Span<felt252>,
    peaks_length: usize,
}

