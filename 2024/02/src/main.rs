use std::io;

use anyhow::Result;
use itertools::Itertools;

fn main() -> Result<()> {
    let mut res = 0;
    for l in io::stdin().lines() {
        let l = l?;
        let data: Vec<u32> = l
            .trim()
            .split_ascii_whitespace()
            .map(|a| a.parse())
            .try_collect()?;
        //res += part1(data.iter().copied()) as u32;
        res += part2(&data) as u32;
    }

    println!("{res}");

    Ok(())
}

fn part1<I: IntoIterator<Item = u32> + Clone>(data: I) -> bool {
    fn check<F: Fn(u32, u32) -> bool, I: Iterator<Item = u32>>(
        mut data: I,
        f: F,
    ) -> bool {
        let mut last = data.next().unwrap();
        for d in data {
            if !f(last, d) || d.abs_diff(last) > 3 {
                return false;
            }
            last = d;
        }
        true
    }

    check(data.clone().into_iter(), |a, b| a < b)
        || check(data.into_iter(), |a, b| a > b)
}

fn part2(data: &[u32]) -> bool {
    // Slow but works
    (0..data.len()).any(|n| {
        part1(
            data.iter()
                .enumerate()
                .filter_map(|(i, v)| (i != n).then_some(*v)),
        )
    })
}
