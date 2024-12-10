use std::{
    collections::{HashMap, HashSet},
    io,
    ops::{Mul, Sub},
};

use anyhow::Result;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct Vec2 {
    x: isize,
    y: isize,
}

impl Vec2 {
    pub fn is_in_size(&self, s: Vec2) -> bool {
        self.x >= 0 && self.y >= 0 && self.x < s.x && self.y < s.y
    }
}

impl Mul<isize> for Vec2 {
    type Output = Vec2;

    fn mul(self, rhs: isize) -> Self::Output {
        (self.x * rhs, self.y * rhs).into()
    }
}

impl Sub<Vec2> for Vec2 {
    type Output = Vec2;

    fn sub(self, rhs: Vec2) -> Self::Output {
        (self.x - rhs.x, self.y - rhs.y).into()
    }
}

impl From<(isize, isize)> for Vec2 {
    fn from((x, y): (isize, isize)) -> Self {
        Vec2 { x, y }
    }
}

fn main() -> Result<()> {
    let mut size: Vec2 = (0, 0).into();
    let mut antenas: HashMap<char, Vec<Vec2>> = HashMap::new();
    for (y, l) in io::stdin().lines().enumerate() {
        let l = l?;
        for (x, c) in l.trim().chars().enumerate() {
            size.x += 1;
            if !c.is_ascii_alphanumeric() {
                continue;
            }
            antenas
                .entry(c)
                .or_default()
                .push((x as isize, y as isize).into());
        }
        size.y += 1;
    }

    // Get the ceiling of average width
    size.x = (size.x + size.y - 1) / size.y;

    let mut antinodes = HashSet::new();

    for a in antenas.values() {
        for i in 0..a.len() - 1 {
            let a1 = a[i];
            for a2 in &a[i + 1..] {
                //part1(&mut antinodes, size, a1, *a2);
                part2(&mut antinodes, size, a1, *a2);
            }
        }
    }

    let res = antinodes.len();

    println!("{res}");

    Ok(())
}

fn part1(r: &mut HashSet<Vec2>, s: Vec2, a1: Vec2, a2: Vec2) {
    r.extend(
        [a1 * 2 - a2, a2 * 2 - a1]
            .into_iter()
            .filter(|a| a.is_in_size(s)),
    );
}

fn part2(r: &mut HashSet<Vec2>, s: Vec2, a1: Vec2, a2: Vec2) {
    for (mut a, d) in [(a1, a2 - a1), (a2, a1 - a2)] {
        while a.is_in_size(s) {
            r.insert(a);
            a = a - d;
        }
    }
}
