use std::{io, ops::AddAssign};

use anyhow::Result;

#[derive(Debug, Clone, Copy)]
struct Vec2<T = usize> {
    x: T,
    y: T,
}

fn main() -> Result<()> {
    let mut data: Vec<Vec<_>> = vec![];
    for l in io::stdin().lines() {
        data.push(l?.chars().collect());
    }

    //let res = part1(&data, "XMAS");
    let res = part2(&data, "MAS");

    println!("{res}");

    Ok(())
}

fn part1(data: &[Vec<char>], s: &str) -> usize {
    let s2: String = s.chars().rev().collect();
    count_inner(data, s) + count_inner(data, &s2)
}

fn part2(data: &[Vec<char>], s: &str) -> usize {
    let mut cnt = 0;
    for y in 0..data.len() {
        for x in 0..data.len() {
            let mut c = has(data, s, (x, y), (1, 1))
                || has(data, s, (x + 2, y + 2), (-1, -1));
            c = c
                && (has(data, s, (x + 2, y), (-1, 1))
                    || has(data, s, (x, y + 2), (1, -1)));
            cnt += c as usize;
        }
    }

    cnt
}

fn count_inner(data: &[Vec<char>], s: &str) -> usize {
    let mut cnt = 0;
    for y in 0..data.len() {
        for x in 0..data.len() {
            cnt += has(data, s, (x, y), (1, 0)) as usize;
            cnt += has(data, s, (x, y), (1, 1)) as usize;
            cnt += has(data, s, (x, y), (0, 1)) as usize;
            cnt += has(data, s, (x + s.len() - 1, y), (-1, 1)) as usize;
        }
    }

    cnt
}

fn has(
    data: &[Vec<char>],
    s: &str,
    pos: impl Into<Vec2>,
    step: impl Into<Vec2<isize>>,
) -> bool {
    let inner = || -> Option<()> {
        let mut pos = pos.into();
        let step = step.into();
        for c in s.chars() {
            if c != at(data, pos)? {
                return None;
            }
            pos += step;
        }
        Some(())
    };
    inner().is_some()
}

fn at(data: &[Vec<char>], pos: Vec2) -> Option<char> {
    if pos.y >= data.len() || pos.x >= data[pos.y].len() {
        None
    } else {
        Some(data[pos.y][pos.x])
    }
}

impl<T> From<(T, T)> for Vec2<T> {
    fn from((x, y): (T, T)) -> Self {
        Self { x, y }
    }
}

impl AddAssign<Vec2<isize>> for Vec2 {
    fn add_assign(&mut self, rhs: Vec2<isize>) {
        self.x = self.x.wrapping_add_signed(rhs.x);
        self.y = self.y.wrapping_add_signed(rhs.y);
    }
}
