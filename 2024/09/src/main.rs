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

fn part2(mut nums: Vec<(usize, usize)>) -> usize {
    let mut id = 0;
    let mut res = 0;
    let mut pos = 0;

    while id < nums.len() {
        let (data, mut space) = nums[id];

        let mut nextid = id + 1;

        while nextid < nums.len() && nums[nextid].0 == 0 {
            space += nums[nextid].0;
            nextid += 1;
        }

        res += (pos..pos + data).sum::<usize>() * id;
        pos += data;

        id = nextid;

        while nums[nums.len() - 1].0 == 0 {
            nums.pop();
        }

        let mut id = nums.len() - 1;
        while space != 0 && id >= nextid {
            let (d, s) = nums[id];
            if d <= space {
                res += (pos..pos + d).sum::<usize>() * id;
                pos += d;
                nums[id] = (0, s + d);
                space -= d;
            }

            id -= 1;
        }
    }

    res
}
