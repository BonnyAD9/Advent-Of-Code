import gleam/yielder
import stdin
import gleam/result
import gleam/list
import gleam/string
import gleam/int
import gleam/io

type Point = #(Int, Int)

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_point)
        |> yielder.to_list()
        |> max_sq()
    
  io.println(int.to_string(res))
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
