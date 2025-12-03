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

fn digit_list(s: String) -> List(#(Int, Int)) {
    string.trim(s)
        |> string.to_graphemes()
        |> yielder.from_list()
        |> yielder.map(parse_digit)
        |> yielder.index()
        |> yielder.to_list()
}

fn parse_digit(s: String) -> Int {
    int.parse(s) |> result.unwrap(0)
}

fn max_joltage(j: List(#(Int, Int))) -> Int {
    // j, second index
    let #(b, i) = list.max(j, fn (a, b) { cmp_ind(a, b, -1) }) |> result.unwrap(#(0, -1))
    let #(s, _) = list.max(j, fn (a, b) { cmp_ind(a, b, i) }) |> result.unwrap(#(0, -1))
    b * 10 + s
}

fn cmp_ind(a: #(Int, Int), b: #(Int, Int), ind: Int) -> order.Order {
    let #(av, ai) = a
    let #(bv, bi) = b
    case True {
        _ if ai > ind && bi > ind -> int.compare(av, bv)
        _ if ai < ind && bi < ind -> int.compare(ai, bi)
        _ if ai > ind -> order.Gt
        _ -> order.Lt
    }
}
