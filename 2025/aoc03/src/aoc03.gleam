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
        |> yielder.map(max_joltage(_, 12)) // 2 for part1
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

fn max_joltage(j: List(#(Int, Int)), cnt: Int) -> Int {
    let len = list.length(j)
    max_joltage0(0, j, len, cnt, -1)
}

fn max_joltage0(cur: Int, j: List(#(Int, Int)), len: Int, cnt: Int, min: Int) -> Int {
    case cnt {
        0 -> cur
        _ -> {
            // assuming that max returns the first maximum (seems to be true)
            let #(dig, ind) =
                list.max(j, fn(a, b) { cmp_ind(a, b, #(min, len - cnt + 1)) })
                |> result.unwrap(#(0, -1))
            max_joltage0(cur * 10 + dig, j, len, cnt - 1, ind)
        }
    }
}

fn cmp_ind(a: #(Int, Int), b: #(Int, Int), r: #(Int, Int)) -> order.Order {
    let #(av, ai) = a
    let #(bv, bi) = b
    let ar = in_range(ai, r)
    let br = in_range(bi, r)
    case ar, br {
        True, True -> int.compare(av, bv)
        False, False -> int.compare(av, bv)
        True, False -> order.Gt
        False, True -> order.Lt
    }
}

fn in_range(n: Int, range: #(Int, Int)) -> Bool {
    n > range.0 && n < range.1
}
