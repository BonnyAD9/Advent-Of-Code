use anyhow::Result;
use itertools::Itertools;
use std::io;

type Int = u64;
type Operator = Box<dyn Fn(Int, Int) -> Int>;

fn main() -> Result<()> {
    let mut res = 0;

    // part1
    //let f: &[Operator] = &[Box::new(|a, b| a + b), Box::new(|a, b| a * b)];
    // part2
    let f: &[Operator] = &[
        Box::new(|a, b| a + b),
        Box::new(|a, b| a * b),
        Box::new(|a, b| {
            if b == 0 {
                a * 10
            } else {
                a * 10_u64.pow((b as f64).log10() as u32 + 1) + b
            }
        })
    ];

    for l in io::stdin().lines() {
        let l = l?;
        let eq: Vec<_> = l.split(":").collect();
        let r: Int = eq[0].trim().parse()?;
        let eq: Vec<Int> = eq[1]
            .trim()
            .split_ascii_whitespace()
            .map(|n| n.parse())
            .try_collect()?;
        if has_solution(r, &eq, f) {
            res += r;
        }
    }
    println!("{res}");
    Ok(())
}

fn has_solution(res: Int, eq: &[Int], f: &[Operator]) -> bool {
    let radix = f.len() as u64;
    let lim = radix.pow((eq.len() - 1) as u32);

    for mut i in 0..lim {
        let mut r = eq[0];
        for n in eq.iter().skip(1) {
            r = f[(i % radix) as usize](r, *n);
            i /= radix;
        }
        if r == res {
            return true;
        }
    }
    false
}
