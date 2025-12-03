import gleam/list
import gleam/order
import gleam/int
import gleam/result
import gleam/string
import gleam/yielder
import stdin
import gleam/io

pub fn main() -> Nil {
    let sum = stdin.read_lines()
        |> yielder.map(digit_list)
        |> yielder.map(max_joltage)
        |> yielder.fold(0, int.add)
    
    io.println(int.to_string(sum))
}

fn digit_list(s: String) -> List(Int) {
    string.trim(s)
        |> string.to_graphemes()
        |> yielder.from_list()
        |> yielder.map(parse_digit)
        |> yielder.to_list()
}

fn parse_digit(s: String) -> Int {
    int.parse(s) |> result.unwrap(0)
}

fn max_joltage(j: List(Int)) -> Int {
    max_joltage0(0, 0, j)
}

fn max_joltage0(b: Int, s: Int, j: List(Int)) -> Int {
    case j {
        [] -> b * 10 + s
        [x] if x > s -> b * 10 + x
        [_] -> b * 10 + s
        [x, y, _, ..] if x > b && y > x -> max_joltage0(b, s, list.drop(j, 1))
        [x, y, ..l] if x > b -> max_joltage0(x, y, l)
        [x, ..l] if x > s -> max_joltage0(b, x, l)
        [_, ..l] -> max_joltage0(b, s, l)
    }
}
