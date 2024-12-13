use std::io::{self, BufReader};

use anyhow::Result;
use itertools::Itertools;
use utf8_chars::BufReadCharsExt;

fn main() -> Result<()> {
    let nums: Vec<_> =  BufReader::new(io::stdin())
        .chars()
        .flatten()
        .map(|c| c.to_digit(10))
        .flatten()
        .map(|a| a as usize)
        .chain([0])
        .tuples::<(_, _)>()
        .collect();

    //let res = part1(nums);
    let res = part2(nums);

    println!("{res}");

    Ok(())
}

fn part1(mut nums: Vec<(usize, usize)>) -> usize {
    let mut id = 0;
    let mut res = 0;
    let mut pos = 0;

    while id < nums.len() {
        let (data, mut space) = nums[id];
        res += (pos..pos + data).sum::<usize>() * id;
        pos += data;

        while space != 0 && id < nums.len() - 1 {
            let id = nums.len() - 1;
            let (d, _) = nums[id];

            let len = space.min(d);
            res += (pos..pos + len).sum::<usize>() * id;
            pos += len;

            space -= len;
            nums[id].0 -= len;

            if nums[id].0 == 0 {
                nums.pop();
            }
        }

        id += 1;
    }

    res
}

fn part2(nums: Vec<(usize, usize)>) -> usize {
    let mut nums: Vec<_> = nums.into_iter().map(|(d, s)| (d, 0, s)).collect();
    let mut res = 0;

    'outer: for id in (0..nums.len()).rev() {
        let (data, additional, space) = nums[id];

        let mut pos = 0;
        for p in 0..id {
            let (d, a, s) = nums[p];
            pos += d + a;
            if s >= data {
                res += (pos..pos + data).sum::<usize>() * id;
                nums[id] = (0, additional, data + space);
                nums[p] = (d, a + data, s - data);
                continue 'outer;
            }
            pos += s;
        }

        res += (pos..pos + data).sum::<usize>() * id;
    }

    res
}
