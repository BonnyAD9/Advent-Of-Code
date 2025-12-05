import gleam/list
import gleam/int
import gleam/result
import gleam/string
import gleam/yielder
import stdin
import gleam/io

pub fn main() -> Nil {
    let ranges = stdin.read_lines()
        |> yielder.take_while(fn (a) { !string.is_empty(string.trim(a)) })
        |> yielder.map(parse_range)
        |> yielder.to_list()

    let part1 = stdin.read_lines()
        |> yielder.map(parse_int)
        |> yielder.fold(0, fn (a, b) { fold_is_in_any_range(a, b, ranges) })

    let part2 = yielder.from_list(ranges)
        |> yielder.fold([], add_range)
        |> yielder.from_list()
        |> yielder.map(range_size)
        |> yielder.reduce(int.add)
        |> result.unwrap(0)

    io.print("part1: ")
    io.println(int.to_string(part1))
    io.print("part2: ")
    io.println(int.to_string(part2))
}

fn range_size(r: #(Int, Int)) -> Int {
    r.1 - r.0 + 1
}

fn add_range(rs: List(#(Int, Int)), r: #(Int, Int)) -> List(#(Int, Int)) {
    add_range0(rs, r, [])
}

fn add_range0(
    rs: List(#(Int, Int)),
    ir: #(Int, Int),
    res: List(#(Int, Int))
) -> List(#(Int, Int)) {
    case rs {
        [] -> [ir, ..res]
        [r, ..] -> {
            let l = list.drop(rs, 1)
            case ranges_overlap(ir, r) {
                True -> add_range0(
                    l,
                    #(int.min(r.0, ir.0), int.max(r.1, ir.1)),
                    res
                )
                False -> add_range0(l, ir, [r, ..res])
            }
        }
    }
}

fn fold_is_in_any_range(cnt: Int, cur: Int, r: List(#(Int, Int))) -> Int {
    case is_in_any_range(cur, r) {
        True -> cnt + 1
        False -> cnt
    }
}

fn is_in_any_range(n: Int, r: List(#(Int, Int))) -> Bool {
    case r {
        [] -> False
        [r, ..l] -> in_range(n, r) || is_in_any_range(n, l)
    }
}

pub fn parse_int(s: String) -> Int {
    s |> string.trim() |> int.parse() |> result.unwrap(0)
}

pub fn parse_range(s: String) -> #(Int, Int) {
    let #(s, e) = s |> string.split_once("-") |> result.unwrap(#("", ""))
    #(
        s |> parse_int(),
        e |> parse_int(),
    )
}

fn in_range(n: Int, r: #(Int, Int)) -> Bool {
    n >= r.0 && n <= r.1
}

fn ranges_overlap(a: #(Int, Int), b: #(Int, Int)) -> Bool {
    in_range(a.0, b) || in_range(b.0, a)
}
