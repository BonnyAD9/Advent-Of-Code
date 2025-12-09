import gleam/order
import gleam/bit_array
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
type TPoint = #(Point, Tag)

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_point)
        |> yielder.to_list()
        |> max_sq()

    io.println(int.to_string(res))
}

fn tag_points(l: List(Point)) -> #(List(TPoint), Tag) {
    let #(res, #(left, right)) = case l {
        [p, n, ..l] -> tag_points0(list.drop(l, 1), p, get_direction(p, n), [], 0, 0)
        _ -> panic
    }
    
}

fn tag_points0(l: List(Point), first: Point, pdir: Point, res: List(TPoint), left: Int, right: Int) -> #(List(TPoint), #(Int, Int)) {
    case l {
        [] -> panic
        [p] -> {
            let cdir = get_direction(p, first)
            case pdir.0 + cdir.0 == pdir.1 + cdir.1 {
                True -> #([#(p, Left), ..res], #(left + 1, right))
                False -> #([#(p, Right), ..res], #(left, right + 1))
            }
        }
        [p, n, ..] -> {
            let cdir = get_direction(p, n)
            case pdir.0 + cdir.0 == pdir.1 + cdir.1 {
                True -> tag_points0(list.drop(l, 1), first, cdir, [#(p, Left), ..res], left + 1, right)
                False -> tag_points0(list.drop(l, 1), first, cdir, [#(p, Right), ..res], left, right + 1)
            }
        }
    }
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

fn max_sq(l: List(Point)) -> Int {
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
