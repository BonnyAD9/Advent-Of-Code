import gleam/io
import gleam/yielder
import gleam/int
import gleam/result
import stdin

pub fn main() -> Nil {
    let sum = stdin.read_lines()
        |> yielder.map(parse_instruction)
        |> yielder.fold(0, int.add)
    io.println(int.to_string({ sum % 100 + 100 } % 100))
}

fn parse_instruction(i: String) -> Int {
    case i {
        "L" <> n -> -{ int.parse(n) |> result.unwrap(0) }
        "R" <> n -> int.parse(n) |> result.unwrap(0)
        _ -> 0
    }
}
