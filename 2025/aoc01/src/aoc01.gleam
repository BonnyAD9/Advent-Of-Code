import gleam/string
import gleam/io
import gleam/yielder
import gleam/int
import gleam/result
import stdin

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_instruction)
        |> yielder.flat_map(expand_num) // part2
        |> yielder.fold(#(0, 50), count_0)

    io.println(int.to_string(res.0))
}

fn parse_instruction(i: String) -> Int {
    case string.trim(i) {
        "L" <> n -> -{ int.parse(n) |> result.unwrap(0) }
        "R" <> n -> int.parse(n) |> result.unwrap(0)
        _ -> 0
    }
}

fn count_0(s: #(Int, Int), i: Int) -> #(Int, Int) {
    let #(c, s) = s
    let s = { s + i } % 100
    case s {
        0 -> #(c + 1, s)
        _ -> #(c, s)
    }
}

fn expand_num(n: Int) -> yielder.Yielder(Int) {
    case n < 0 {
        True -> yielder.repeat(-1) |> yielder.take(-n)
        False -> yielder.repeat(1) |> yielder.take(n)
    }
}