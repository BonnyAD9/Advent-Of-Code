use std::io;

use anyhow::Result;

// I should have chosen C#, utf8 is anoying

fn main() -> Result<()> {
    let mut res = 0;
    for l in io::stdin().lines() {
        let l = l?;
        //let is_nice = part1(&l);
        let is_nice = part2(&l);
        if is_nice {
            res += 1;
        }
    }

    println!("{res}");

    Ok(())
}

fn part1(s: &str) -> bool {
    const FORBIDDEN: &[&str] = &["ab", "cd", "pq", "xy"];

    if FORBIDDEN.iter().any(|no| s.contains(no)) {
        return false;
    }

    const VOWEL: &str = "aeiou";
    const VOWEL_CNT: usize = 3;

    if s.chars().filter(|c| VOWEL.contains(*c)).count() < VOWEL_CNT {
        return false;
    }

    let mut chrs = s.chars().peekable();
    while let Some(c) = chrs.next() {
        if chrs.peek().copied() == Some(c) {
            return true;
        }
    }

    false
}

fn part2(s: &str) -> bool {
    let mut rule1 = false;
    let mut rule2 = false;

    let mut chrs = s.char_indices();
    while let Some((i1, c1)) = chrs.next() {
        let mut chrs = chrs.clone();
        chrs.next();
        let Some((i2, c2)) = chrs.next() else {
            return false;
        };
        rule1 = rule1 || s[i2..].contains(&s[i1..i2]);
        rule2 = rule2 || c1 == c2;

        if rule1 && rule2 {
            return true;
        }
    }

    false
}
