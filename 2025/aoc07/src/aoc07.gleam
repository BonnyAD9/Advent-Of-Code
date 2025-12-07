import gleam/int
import gleam/yielder
import stdin
import gleam/list
import gleam/string
import gleam/io

type Cell {
    Laser
    Split
    None
}

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_line)
        |> yielder.to_list()
        |> count_splits()
    
    io.println(int.to_string(res))
}

fn count_splits(b: List(List(Cell))) -> Int {
    case b {
        [] -> 0
        [s, ..b] -> count_splits0(b, s, 0)
    }
}

fn count_splits0(b: List(List(Cell)), s: List(Cell), cnt: Int) -> Int {
    case b {
        [] -> cnt
        [l, ..b] -> {
            let #(c, ns) = split_line(l, s)
            count_splits0(b, ns, cnt + c)
        }
    }
}

fn split_line(l: List(Cell), s: List(Cell)) -> #(Int, List(Cell)) {
    let #(n, r) = split_line0(l, s, [], 0, False)
    #(n, list.reverse(r))
}

fn split_line0(l: List(Cell), s: List(Cell), res: List(Cell), cnt: Int, set: Bool) -> #(Int, List(Cell)) {
    case s, l {
        [], [] -> #(cnt, res)
        [Laser, ..sr], [Split, ..l] -> split_line0(l, sr, [None, ..res], cnt + 1, True)
        [_, ..sr], [Split, ..l] ->  split_line0(l, sr, [None, ..res], cnt, False)
        [_, ..sr], [Laser, ..l] -> split_line0(l, sr, [Laser, ..res], cnt, False)
        [sv, ..sr], [_, ..l] if set || sv == Laser -> split_line0(l, sr, [Laser, ..res], cnt, False)
        [_, Laser, ..], [_, Split, ..] -> split_line0(list.drop(l, 1), list.drop(s, 1), [Laser, ..res], cnt, False)
        [_, ..sr], [_, ..l] -> split_line0(l, sr, [None, ..res], cnt, False)
        _, _ -> panic
    }
}

fn parse_line(l: String) -> List(Cell) {
    l |> string.trim() |> string.to_graphemes() |> list.map(parse_item)
}

fn parse_item(i: String) -> Cell {
    case i {
        "." -> None
        "^" -> Split
        "S" -> Laser
        _ -> panic
    }
}
