use std::io;

use anyhow::Result;

type Vec2 = (isize, isize);

fn main() -> Result<()> {
    let mut map = vec![];
    for l in io::stdin().lines() {
        let l = l?;
        let line: Vec<_> = l.trim().chars().map(|c| (c, false)).collect();
        map.push(line);
    }

    let mut res = 0;
    for y in 0..map.len() {
        for x in 0..map[y].len() {
            let (a, p) = price(&mut map, (x as isize, y as isize));
            res += a * p;
        }
    }

    println!("{res}");

    Ok(())
}

fn price(map: &mut [Vec<(char, bool)>], (x, y): Vec2) -> (u64, u64) {
    let (typ, checked) = at(map, (x, y));
    if checked {
        return (0, 0);
    }

    map[y as usize][x as usize].1 = true;

    fn adj(map: &mut [Vec<(char, bool)>], chr: char, (x, y): Vec2, a: &mut u64, p: &mut u64) {
        let (typ, _) = at(map, (x, y));
        if chr != typ {
            *p += 1;
            return;
        }
        let (ac, pc) = price(map, (x, y));
        *a += ac;
        *p += pc;
    }

    let mut res = (1, 0);

    adj(map, typ, (x - 1, y), &mut res.0, &mut res.1);
    adj(map, typ, (x, y - 1), &mut res.0, &mut res.1);
    adj(map, typ, (x + 1, y), &mut res.0, &mut res.1);
    adj(map, typ, (x, y + 1), &mut res.0, &mut res.1);

    res
}

fn at(map: &[Vec<(char, bool)>], (x, y): Vec2) -> (char, bool) {
    if x < 0 || y < 0 || y as usize >= map.len() || x as usize >= map[y as usize].len() {
        (' ', true)
    } else {
        map[y as usize][x as usize]
    }
}
