use std::io;
use anyhow::Result;
use itertools::Itertools;

fn main() -> Result<()> {
    let mut res = 0;
    for l in io::stdin().lines() {
        let l = l?;
        let eq: Vec<_> = l.split(":").collect();
        let r: i64 = eq[0].trim().parse()?;
        let eq: Vec<i64> = eq[1]
            .trim()
            .split_ascii_whitespace()
            .map(|n| n.parse())
            .try_collect()?;
        if has_solution(r, &eq) {
            res += r;
        }
    }
    println!("{res}");
    Ok(())
}

fn has_solution(res: i64, eq: &[i64]) -> bool {
    let lim = 1 << (eq.len() - 1) as u64;

   for mut i in 0..lim {
        let mut r = eq[0];
        for n in eq.iter().skip(1) {
            if (i & 1) == 1 {
                r *= n;
            } else {
                r += n;
            }
            i >>= 1;
        }
        if r == res {
            return true;
        }
   }
   false
}
