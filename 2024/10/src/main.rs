use std::{collections::HashSet, io};

use anyhow::Result;

type Vec2 = (isize, isize);

#[derive(Default)]
struct BasicCounter(usize);

impl BasicCounter {
    fn len(&self) -> usize {
        self.0
    }

    fn insert<T>(&mut self, _: T) {
        self.0 += 1;
    }
}

//type Cnt = HashSet<Vec2>; // part1
type Cnt = BasicCounter; // part2

fn main() -> Result<()> {
    let mut map = vec![];

    for l in io::stdin().lines() {
        let l = l?;
        let line: Vec<_> = l
            .trim()
            .chars()
            .map(|c| c.to_digit(10).unwrap_or(10))
            .collect();
        map.push(line);
    }

    let mut res = 0;
    for (y, l) in map.iter().enumerate() {
        for (x, v) in l.iter().enumerate() {
            if *v == 0 {
                let v = count_trails(&map, (x as isize, y as isize));
                res += v;
            }
        }
    }

    println!();
    println!("{res}");

    Ok(())
}

fn count_trails(map: &[Vec<u32>], pos: Vec2) -> usize {
    let mut nines = Cnt::default();
    let mut to_visit = vec![pos];

    while let Some((x, y)) = to_visit.pop() {
        let cur = at(map, (x, y)).unwrap();
        if cur >= 9 {
            nines.insert((x, y));
            continue;
        }

        to_visit.extend(
            [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
                .into_iter()
                .filter(|p: &Vec2| {
                    matches!(at(map, *p), Some(s) if s > cur && s - cur == 1)
                }),
        );
    }

    nines.len()
}

fn at(map: &[Vec<u32>], (x, y): Vec2) -> Option<u32> {
    if y < 0
        || x < 0
        || y as usize >= map.len()
        || x as usize >= map[y as usize].len()
    {
        None
    } else {
        Some(map[y as usize][x as usize])
    }
}
