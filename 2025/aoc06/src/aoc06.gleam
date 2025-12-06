import gleam/yielder
import stdin
import gleam/list
import gleam/string
import gleam/result
import gleam/int
import gleam/io

pub fn main() -> Nil {
    let lines = stdin.read_lines()
        |> yielder.map(parse_line)
        |> yielder.to_list()
        |> list.reverse()
    
    let res = case lines {
        [op, ..data] -> calculate_all(op, data)
        _ -> 0
    }
    
    io.println(int.to_string(res))
}

fn calculate_all(op: List(Int), data: List(List(Int))) -> Int {
    calculate_all0(op, data, 0)
}

fn calculate_all0(op: List(Int), data: List(List(Int)), sum: Int) -> Int {
    case op {
        [] -> sum
        [o, ..op] -> {
            let #(res, data2) = calculate(o, data)
            calculate_all0(op, data2, sum + res)
        }
    }
}

fn calculate(op: Int, data: List(List(Int))) -> #(Int, List(List(Int))) {
    calculate0(op, data, op, [])
}

fn calculate0(op: Int, data: List(List(Int)), res: Int, rem: List(List(Int)))
    -> #(Int, List(List(Int)))
{
    case data {
        [] -> #(res, rem)
        [[n, ..ns], ..data] ->
            calculate0(op, data, execute_operator(op, res, n), [ns, ..rem])
        _ -> panic
    }
}

fn execute_operator(op: Int, a: Int, b: Int) -> Int {
    case op {
        0 -> a + b
        1 -> a * b
        _ -> panic
    }
}

fn parse_line(l: String) -> List(Int) {
    split_by_spaces(string.trim(l)) |> list.map(parse_number)
}

fn parse_number(s: String) -> Int {
    case string.trim(s) {
        "+" -> 0
        "*" -> 1
        n -> int.parse(n) |> result.unwrap(0)
    }
}

fn split_by_spaces(s: String) -> List(String) {
    let s2 = string.replace(s, "  ", " ")
    case string.byte_size(s) == string.byte_size(s2) {
        True -> string.split(s, " ")
        False -> split_by_spaces(s2)
    }
}
