import gleam/int
import gleam/yielder
import stdin
import gleam/string
import gleam/bool
import gleam/result
import gleam/list
import gleam/dict.{type Dict}
import gleam/io

const large: Int = 9_223_372_036_854_775_807
const large_point: Point = Point(large, large, large)

pub type Point {
    Point(Int, Int, Int)
}

pub type Group = Dict(Point, Bool)
pub type Pair = #(Point, Point)
pub type GroupConnection = #(Pair, #(Group, Group))

pub fn main() -> Nil {
    let points = stdin.read_lines()
        |> yielder.map(parse_point)
        |> yielder.to_list()

    // part1
    // let res = points |> connect_n(1000) |> mul_max_group_sizes(3)
    // part2
    let res = points
        |> list.map(fn(p) { dict.from_list([#(p, True)]) })
        |> last_pair_xmul() // part2

    io.println(int.to_string(res))
}

// part2

pub fn last_pair_xmul(g: List(Group)) -> Int {
    let #(Point(a, _, _), Point(b, _, _)) = last_pair_group_join(g)
    a * b
}

// returns last pair
fn last_pair_group_join(g: List(Group)) -> Pair {
    case g {
        [] -> #(large_point, large_point)
        [_] -> #(large_point, large_point)
        [_, _] -> closest_group_pair(g).0
        _ -> {
            let #(#(av, bv), #(a, b)) = closest_group_pair(g)
            let rest = list.filter(g, fn(d) {
                !dict.has_key(d, av) && !dict.has_key(d, bv)
            })
            last_pair_group_join([dict.combine(a, b, bool.and), ..rest])
        }
    }
}

fn closest_group_pair(g: List(Group)) -> GroupConnection {
    closest_group_pair0(
        g,
        #(#(large_point, large_point), #(dict.new(), dict.new())),
        large
    )
}

fn closest_group_pair0(g: List(Group), best: GroupConnection, bestd: Int)
    -> GroupConnection
{
    case g {
        [] -> best
        [_] -> best
        [g, ..rg] -> {
            let #(dist, point, group) = closest_group(rg, g)
            case dist < bestd {
                True -> closest_group_pair0(rg, #(point, #(g, group)), dist)
                False -> closest_group_pair0(rg, best, bestd)
            }
        }
    }
}

fn closest_group(g: List(Group), p: Group) -> #(Int, Pair, Group) {
    closest_group0(g, p, #(#(large_point, large_point), dict.new()), large)
}

fn closest_group0(g: List(Group), p: Group, best: #(Pair, Group), bestd: Int)
    -> #(Int, Pair, Group)
{
    case g {
        [] -> #(bestd, best.0, best.1)
        [a, ..g] -> {
            let #(dist, point) = group_distance(a, p)
            case dist < bestd {
                True -> closest_group0(g, p, #(point, a), dist)
                False -> closest_group0(g, p, best, bestd)
            }
        }
    }
}

fn group_distance(a: Group, b: Group) -> #(Int, Pair) {
    group_distacne0(
        dict.keys(a),
        dict.keys(b),
        #(large_point, large_point),
        large
    )
}

fn group_distacne0(a: List(Point), b: List(Point), best: Pair, bestd: Int)
    -> #(Int, Pair)
{
    case a {
        [] -> #(bestd, best)
        [a, ..ra] -> {
            let #(dist, p) = closest(b, a)
            case dist < bestd {
                True -> group_distacne0(ra, b, #(a, p), dist)
                False -> group_distacne0(ra, b, best, bestd)
            }
        }
    }
}

fn closest(l: List(Point), p: Point) -> #(Int, Point) {
    closest0(l, p, large_point, large)
}

fn closest0(l: List(Point), p: Point, best: Point, bestd: Int)
    -> #(Int, Point)
{
    case l {
        [] -> #(bestd, best)
        [a, ..l] -> {
            let dist = dist_sq(a, p)
            case dist < bestd {
                True -> closest0(l, p, a, dist)
                False -> closest0(l, p, best, bestd)
            }
        }
    }
}

// part1

pub fn connect_n(p: List(Point), con: Int) -> List(Group) {
    connect_n0(p, con, dict.new())
        |> dict.keys()
        |> list.fold([], add_connection)
}

fn connect_n0(p: List(Point), con: Int, g: Dict(Pair, Bool))
    -> Dict(Pair, Bool)
{
    case con {
         0 -> g
         _ -> {
             let pr =
                closest_pair_of(p, fn(a, b) { !dict.has_key(g, #(a, b)) })
             connect_n0(p, con - 1, dict.insert(g, pr, True))
         }
     }
}

pub fn mul_max_group_sizes(g: List(Group), n: Int) -> Int {
    list.sort(g, fn (a, b) { int.compare(dict.size(b), dict.size(a)) })
        |> yielder.from_list()
        |> yielder.map(dict.size)
        |> yielder.take(n)
        |> yielder.fold(1, int.multiply)
}

fn parse_point(s: String) -> Point {
    let spl = s
        |> string.trim()
        |> string.split(",")
        |> list.try_map(int.parse)
        |> result.lazy_unwrap(fn () {panic})
    case spl {
        [x, y, z] -> Point(x, y, z)
        _ -> panic
    }
}

fn add_connection(d: List(Group), c: Pair) -> List(Group) {
    let #(a, b) = c
    let da = list.find(d, dict.has_key(_, a))
        |> result.lazy_unwrap(fn (){ dict.from_list([#(a, True)]) })
    let db = list.find(d, dict.has_key(_, b))
        |> result.lazy_unwrap(fn (){ dict.from_list([#(b, True)]) })

    let rest =
        list.filter(d, fn(d) { !dict.has_key(d, a) && !dict.has_key(d, a) })
    [dict.combine(da, db, bool.or), ..rest]
}

fn closest_pair_of(d: List(Point), f: fn(Point, Point) -> Bool) -> Pair {
    closest_pair_of0(d, f, #(large_point, large_point), large)
}

fn closest_pair_of0(
    d: List(Point),
    f: fn(Point, Point) -> Bool,
    best: Pair,
    bestd: Int
) -> Pair {
    case d {
        [] -> best
        [_] -> best
        [a, ..d] -> {
            let pt = closest_of(d, a, f)
            let dist = dist_sq(pt, a)
            case dist < bestd {
                True -> closest_pair_of0(d, f, #(a, pt), dist)
                _ -> closest_pair_of0(d, f, best, bestd)
            }
        }
    }
}

fn closest_of(d: List(Point), p: Point, f: fn(Point, Point) -> Bool) -> Point {
    closest_not_of0(d, p, f, large_point, large)
}

fn closest_not_of0(
    d: List(Point),
    p: Point,
    f: fn(Point, Point) -> Bool,
    best: Point,
    bestd: Int
) -> Point {
    case d {
        [] -> best
        [a, ..d] -> {
            let dist = dist_sq(p, a)
            case dist < bestd && f(p, a) {
                True -> closest_not_of0(d, p, f, a, dist)
                False -> closest_not_of0(d, p, f, best, bestd)
            }
        }
    }
}

fn dist_sq(a: Point, b: Point) -> Int {
    let Point(x, y, z) = a
    let Point(a, b, c) = b
    let x = x - a
    let y = y - b
    let z = z - c
    x * x + y * y + z * z
}
