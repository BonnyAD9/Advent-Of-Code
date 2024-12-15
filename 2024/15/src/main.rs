use std::{io::{self, BufReader}, ops::{Add, AddAssign, Index, IndexMut}};

use anyhow::{bail, Result};
use utf8_chars::BufReadCharsExt;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct Vec2 {
    x: isize,
    y: isize,
}

#[derive(Copy, Clone, Debug, PartialEq, Eq)]
enum Tile {
    Empty,
    Wall,
    Box,
    Robot,
}

struct Room {
    robot: Vec2,
    map: Vec<Vec<Tile>>,
}

fn main() -> Result<()> {
    let mut map = vec![];
    let mut robot: Vec2 = (0, 0).into();

    for l in io::stdin().lines() {
        let l = l?;
        if l.is_empty() {
            break;
        }
        let line: Vec<_> = l.trim().chars().map(Tile::from_char).enumerate().map(|(x, t)| {
            if t == Tile::Robot {
                robot = (x as isize, map.len() as isize).into();
                Tile::Empty
            } else {
                t
            }
        }).collect();
        map.push(line);
    }

    let mut room = Room::new(map, robot);

    for c in BufReader::new(io::stdin()).chars() {
        let c = c?;
        if c.is_whitespace() {
            continue;
        }
        let d = Vec2::chr_dir(c);
        if d == (0, 0).into() {
            bail!("Invalid direction `{c}`.");
        }
        room.step(d);
    }

    let res = room.box_gps();

    println!("{res}");

    Ok(())
}

impl Room {
    pub fn new(map: Vec<Vec<Tile>>, robot: Vec2) -> Self {
        Self { map, robot }
    }

    pub fn step(&mut self, d: Vec2) {
        let mut pos = self.robot + d;
        while self[pos] == Tile::Box {
            pos += d;
        }
        if self[pos] == Tile::Empty {
            self[pos] = Tile::Box;
            self.robot += d;
            let p = self.robot;
            self[p] = Tile::Empty;
        }
    }

    pub fn box_gps(&self) -> isize {
        let mut res = 0;
        for (y, l) in self.map.iter().enumerate() {
            for (x, t) in l.iter().enumerate() {
                if *t == Tile::Box {
                    res += Vec2 { x: x as isize, y: y as isize }.to_gps();
                }
            }
        }
        res
    }
}

impl Vec2 {
    fn chr_dir(c: char) -> Self {
        match c {
            '<' => (-1, 0),
            '^' => (0, -1),
            '>' => (1, 0),
            'v' => (0, 1),
            _ => (0, 0),
        }.into()
    }

    fn to_gps(&self) -> isize {
        self.y * 100 + self.x
    }
}

impl Tile {
    fn from_char(c: char) -> Self {
        match c {
            '#' => Self::Wall,
            'O' => Self::Box,
            '@' => Self::Robot,
            _ => Self::Empty,
        }
    }
}

impl From<(isize, isize)> for Vec2 {
    fn from((x, y): (isize, isize)) -> Self {
        Self { x, y }
    }
}

impl Index<Vec2> for Room {
    type Output = Tile;

    fn index(&self, Vec2 { x, y }: Vec2) -> &Self::Output {
        &self.map[y as usize][x as usize]
    }
}

impl IndexMut<Vec2> for Room {
    fn index_mut(&mut self, Vec2 { x, y }: Vec2) -> &mut Self::Output {
        &mut self.map[y as usize][x as usize]
    }
}

impl Add<Vec2> for Vec2 {
    type Output = Vec2;

    fn add(self, rhs: Vec2) -> Self::Output {
        (self.x + rhs.x, self.y + rhs.y).into()
    }
}

impl AddAssign<Vec2> for Vec2 {
    fn add_assign(&mut self, rhs: Vec2) {
        *self = *self + rhs;
    }
}
