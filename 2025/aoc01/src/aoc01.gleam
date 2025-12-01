import gleam/string
import gleam/io
import gleam/yielder
import gleam/int
import gleam/result
import stdin

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_instruction)
        |> yielder.fold(#(0, 50), zeros_fold)

    io.println(int.to_string(res.0))
}

fn zeros_fold(s: #(Int, Int), i: Int) -> #(Int, Int) {
    let #(c, s) = s
    let s = { s + i } % 100
    case s {
        0 -> #(c + 1, s)
        _ -> #(c, s)
    }
}

fn parse_instruction(i: String) -> Int {
    case string.trim(i) {
        "L" <> n -> -{ int.parse(n) |> result.unwrap(0) }
        "R" <> n -> int.parse(n) |> result.unwrap(0)
        _ -> 0
    }
}
