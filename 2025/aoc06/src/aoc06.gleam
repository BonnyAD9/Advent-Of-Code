import gleam/yielder
import stdin
import gleam/list
import gleam/string
import gleam/result
import gleam/int
import gleam/io

pub fn main() -> Nil {
    // let res = part1()
    let res = part2()
    
    io.println(int.to_string(res))
}

pub fn part1() -> Int {
    let lines = stdin.read_lines()
        |> yielder.map(parse_line)
        |> yielder.to_list()
        |> list.reverse()
    
    case lines {
        [op, ..data] -> calculate_all(op, data)
        _ -> 0
    }
}

pub fn part2() -> Int {
    stdin.read_lines()
        |> yielder.map(string.to_graphemes)
        |> yielder.to_list()
        |> list.transpose()
        |> yielder.from_list()
        |> yielder.map(string.join(_, ""))
        |> yielder.map(parse_line)
        |> yielder.to_list()
        |> continuous_sum_calculate()
}

fn continuous_sum_calculate(data: List(List(Int))) -> Int {
    continuous_sum_calculate0(data, 0, 0, 0)
}

fn continuous_sum_calculate0(
    data: List(List(Int)),
    sum: Int,
    op: Int,
    res: Int) -> Int
{
    case data {
        [] -> sum + res
        [[n, op], ..data] -> {
            continuous_sum_calculate0(data, sum + res, op, n)
        }
        [[n], ..data] -> continuous_sum_calculate0(
            data,
            sum,
            op,
            execute_operator(op, res, n)
        )
        [[], ..data] -> continuous_sum_calculate0(data, sum + res, 0, 0)
        _ -> panic
    }
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
    case string.trim(l) {
        "" -> []
        l -> {
            case string.ends_with(l, "*") || string.ends_with(l, "+") {
                True -> {
                    let n = string.trim(string.drop_end(l, 1))
                    let op = string.last(l) |> result.unwrap("+")
                    split_by_spaces(n)
                        |> list.map(parse_number)
                        |> list.append([parse_number(op)])
                }
                False -> split_by_spaces(l) |> list.map(parse_number)
            }
        }
    }
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
