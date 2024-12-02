use std::io;

use anyhow::Result;

fn main() -> Result<()> {
    let mut a = vec![];
    let mut b = vec![];
    read(&mut a, &mut b)?;

    // part1(a, b);
    part2(a, b);

    Ok(())
}

fn part1(mut a: Vec<u32>, mut b: Vec<u32>) {
    a.sort();
    b.sort();

    let mut res = 0;
    for (a, b) in a.into_iter().zip(b) {
        res += a.abs_diff(b);
    }

    println!("{res}");
}

fn part2(a: Vec<u32>, b: Vec<u32>) {
    let mut res = 0;
    for a in a {
        // slow but works
        res += a as usize * b.iter().filter(|b| **b == a).count();
    }

    println!("{res}");
}

fn read(a: &mut Vec<u32>, b: &mut Vec<u32>) -> Result<()> {
    // slow but works
    for l in io::stdin().lines() {
        let l = l?;
        let r: Vec<_> = l.trim().split_ascii_whitespace().collect();
        if r.len() != 2 {
            break;
        }
        a.push(r[0].parse()?);
        b.push(r[1].parse()?);
    }

    Ok(())
}
