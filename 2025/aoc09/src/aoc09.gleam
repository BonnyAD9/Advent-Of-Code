import gleam/order
import gleam/yielder
import stdin
import gleam/result
import gleam/list
import gleam/string
import gleam/int
import gleam/io

type Tag {
    Left
    Right
}

type Point = #(Int, Int)
type TPoint = #(Point, Tag, Point)

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_point)
        |> yielder.to_list()
        // |> max_sq() // part1
        |> max_filled_sq() // part2

    io.println(int.to_string(res))
}

pub fn max_filled_sq(l: List(Point)) -> Int {
    let #(tl, in) = tag_points(l)
    max_sq_if(tl, fn(a, b) { filled_square(a, b, l, in) })
}

fn filled_square(a: TPoint, b: TPoint, l: List(Point), in: Tag) -> Bool {
    let ab = get_direction(a.0, b.0)
    let ba = get_direction(b.0, a.0)
    is_direction_in(a, ab, in)
        && is_direction_in(b, ba, in)
        && !is_square_intersected(a.0, b.0, l)
}

fn is_square_intersected(a: Point, b: Point, l: List(Point)) -> Bool {
    case l {
        [] -> False
        [f, ..] -> is_square_intersected0(
            #(int.min(a.0, b.0), int.max(a.0, b.0)),
            #(int.min(a.1, b.1), int.max(a.1, b.1)),
            l,
            f
        )
    }
}

fn is_square_intersected0(
    lr: Point,
    tb: Point,
    l: List(Point),
    first: Point
) -> Bool {
    case l {
        [] -> False
        [a] -> intersects_rect(lr, tb, a, first)
        [a, b, ..] -> intersects_rect(lr, tb, a, b)
            || is_square_intersected0(lr, tb, list.drop(l, 1), first)
    }
}

fn intersects_rect(lr: Point, tb: Point, a: Point, b: Point) -> Bool {
    let alr = range_sign(lr, a.0)
    let atb = range_sign(tb, a.1)
    let blr = range_sign(lr, b.0)
    let btb = range_sign(tb, b.1)

    { alr == 0 && atb == 0 }
        || { blr == 0 && btb == 0 }
        || { alr == 0 && blr == 0 && atb != btb }
        || { atb == 0 && btb == 0 && alr != blr }
}

fn range_sign(r: Point, n: Int) -> Int {
    case n <= r.0, n >= r.1 {
        True, False -> -1
        False, True -> 1
        True, True -> 1
        _, _ -> 0
    }
}

fn is_direction_in(p: TPoint, d: Point, in: Tag) -> Bool {
    d.0 == 0
        || d.1 == 0
        || { p.1 == in && p.2 == d }
        || { p.1 != in && p.2 != d }
}

fn max_sq_if(l: List(TPoint), f: fn(TPoint, TPoint) -> Bool) -> Int {
    max_sq_if0(l, f, 0)
}

fn max_sq_if0(l: List(TPoint), f: fn(TPoint, TPoint) -> Bool, best: Int) -> Int
{
    case l {
        [] -> best
        [_] -> best
        [a, ..l] -> {
            let area = max_sq_to_if(l, a, f)
            case area > best {
                True -> max_sq_if0(l, f, area)
                False -> max_sq_if0(l, f, best)
            }
        }
    }
}

fn max_sq_to_if(l: List(TPoint), p: TPoint, f: fn(TPoint, TPoint) -> Bool)
    -> Int
{
    max_sq_to_if0(l, p, f, 0)
}

fn max_sq_to_if0(
    l: List(TPoint),
    p: TPoint,
    f: fn(TPoint, TPoint) -> Bool,
    best: Int
) -> Int {
    case l {
        [] -> best
        [a, ..l] -> {
            let area = get_area(a.0, p.0)
            case area > best && f(a, p) {
                True -> max_sq_to_if0(l, p, f, area)
                False -> max_sq_to_if0(l, p, f, best)
            }
        }
    }
}

fn tag_points(l: List(Point)) -> #(List(TPoint), Tag) {
    let #(res, #(left, right)) = case l {
        [p, n, ..] ->
            tag_points0(list.drop(l, 1), p, get_direction(p, n), [], 0, 0)
        _ -> panic
    }

    case left > right {
        True -> #(res, Left)
        False -> #(res, Right)
    }
}

fn tag_points0(
    l: List(Point),
    first: Point,
    pdir: Point,
    res: List(TPoint),
    left: Int,
    right: Int
) -> #(List(TPoint), #(Int, Int)) {
    case l {
        [] -> panic
        [p] -> {
            let cdir = get_direction(p, first)
            let dirs = #(pdir.1 + cdir.1, -pdir.0 - cdir.0)
            case dirs.0 == dirs.1 {
                True -> #([#(p, Right, dirs), ..res], #(left, right + 1))
                False -> #([#(p, Left, dirs), ..res], #(left + 1, right))
            }
        }
        [p, n, ..] -> {
            let cdir = get_direction(p, n)
            let d = #(-pdir.1 -cdir.1, pdir.0 + cdir.0)
            case is_left_turn(pdir, cdir) {
                True -> tag_points0(
                    list.drop(l, 1),
                    first,
                    cdir,
                    [#(p, Left, #(-d.0, -d.1)), ..res],
                    left + 1,
                    right
                )
                False -> tag_points0(
                    list.drop(l, 1),
                    first,
                    cdir,
                    [#(p, Right, d), ..res],
                    left,
                    right + 1
                )
            }
        }
    }
}

fn is_left_turn(a: Point, b: Point) -> Bool {
    #(a.1, -a.0) == b
}

fn get_direction(a: Point, b: Point) -> Point {
    let #(x, y) = a
    let #(a, b) = b
    #(sign(a - x), sign(b - y))
}

fn sign(n: Int) -> Int {
    case int.compare(n, 0) {
        order.Lt -> -1
        order.Eq -> 0
        order.Gt -> 1
    }
}

fn parse_point(s: String) -> Point {
    let l = string.trim(s)
        |> string.split(",")
        |> list.try_map(int.parse)
        |> result.unwrap([])
    case l {
        [a, b] -> #(a, b)
        _ -> panic
    }
}

pub fn max_sq(l: List(Point)) -> Int {
    max_sq0(l, 0)
}

fn max_sq0(l: List(Point), best: Int) -> Int {
    case l {
        [] -> best
        [_] -> best
        [a, ..l] -> {
            let area = max_sq_to(l, a)
            case area > best {
                True -> max_sq0(l, area)
                False -> max_sq0(l, best)
            }
        }
    }
}

fn max_sq_to(l: List(Point), p: Point) -> Int {
    max_sq_to0(l, p, 0)
}

fn max_sq_to0(l: List(Point), p: Point, best: Int) -> Int {
    case l {
        [] -> best
        [a, ..l] -> {
            let area = get_area(a, p)
            case area > best {
                True -> max_sq_to0(l, p, area)
                False -> max_sq_to0(l, p, best)
            }
        }
    }
}

fn get_area(a: Point, b: Point) -> Int {
    let #(x, y) = a
    let #(a, b) = b
    {int.absolute_value(x - a) + 1} * {int.absolute_value(y - b) + 1}
}
