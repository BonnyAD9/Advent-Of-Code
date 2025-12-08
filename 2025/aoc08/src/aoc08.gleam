import gleam/int
import gleam/yielder
import stdin
import gleam/string
import gleam/bool
import gleam/result
import gleam/list
import gleam/dict.{type Dict}
import gleam/order
import gleam/float
import gleam/io

const large: Float = 9999999999999999999999999999.
const large_point: Point = Point(large, large, large)

type Point {
    Point(Float, Float, Float)
}

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_point)
        |> yielder.to_list()
        |> connect(1000)
        |> mul_max_group_sizes(3)
    
    io.println(int.to_string(res))
}

fn connect(p: List(Point), con: Int) -> List(Dict(Point, Bool)) {
    connect0(p, con, dict.new())
        |> dict.keys()
        |> list.fold([], add_connection)
}

fn connect0(p: List(Point), con: Int, g: Dict(#(Point, Point), Bool)) -> Dict(#(Point, Point), Bool) {
    case con {
         0 -> g
         _ -> {
             let pr = closest_pair_not_of(p, fn(a, b) { !dict.has_key(g, #(a, b)) })
             connect0(p, con - 1, dict.insert(g, pr, True))
         }
     }
}

fn mul_max_group_sizes(g: List(Dict(Point, Bool)), n: Int) -> Int {
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
        |> list.map(int.to_float)
    case spl {
        [x, y, z] -> Point(x, y, z)
        _ -> panic
    }
}

fn add_connection(d: List(Dict(Point, Bool)), c: #(Point, Point)) -> List(Dict(Point, Bool)) {
    let #(a, b) = c
    let da = list.find(d, dict.has_key(_, a)) |> result.lazy_unwrap(fn (){ dict.from_list([#(a, True)]) })
    let db = list.find(d, dict.has_key(_, b)) |> result.lazy_unwrap(fn (){ dict.from_list([#(b, True)]) })
    
    [ dict.combine(da, db, bool.or), ..list.filter(d, fn(d) { !dict.has_key(d, a) && !dict.has_key(d, a) }) ]
}

fn closest_pair_not_of(d: List(Point), f: fn(Point, Point) -> Bool) -> #(Point, Point) {
    closest_pair_not_of0(d, f, #(large_point, large_point), large)
}

fn closest_pair_not_of0(d: List(Point), f: fn(Point, Point) -> Bool, best: #(Point, Point), bestd: Float) -> #(Point, Point) {
    case d {
        [] -> best
        [_] -> best
        [a, ..d] -> {
            let pt = closest_not_of(d, a, f)
            let dist = dist_sq(pt, a)
            case float.compare(dist, bestd) {
                order.Lt -> closest_pair_not_of0(d, f, #(a, pt), dist)
                _ -> closest_pair_not_of0(d, f, best, bestd)
            }
        }
    }
}

fn closest_not_of(d: List(Point), p: Point, f: fn(Point, Point) -> Bool) -> Point {
    closest_not_of0(d, p, f, large_point, large)
}

fn closest_not_of0(d: List(Point), p: Point, f: fn(Point, Point) -> Bool, best: Point, bestd: Float) -> Point {
    case d {
        [] -> best
        [a, ..d] -> {
            let dist = dist_sq(p, a)
            case float.compare(dist, bestd) == order.Lt && f(p, a) {
                True -> closest_not_of0(d, p, f, a, dist)
                False -> closest_not_of0(d, p, f, best, bestd)
            }
        }
    }
}

fn dist_sq(a: Point, b: Point) -> Float {
    let Point(x, y, z) = a
    let Point(a, b, c) = b
    let x = float.subtract(x, a)
    let y = float.subtract(y, b)
    let z = float.subtract(z, c)
    float.add(float.multiply(x, x), float.multiply(y, y)) |> float.add(float.multiply(z, z))
}
