import gleam/int
import gleam/yielder
import stdin
import gleam/list
import gleam/string
import gleam/io

pub type Cell {
    Laser(Int)
    Split
    None
}

pub fn main() -> Nil {
    let #(part1, part2) = stdin.read_lines()
        |> yielder.map(parse_line)
        |> yielder.to_list()
        |> count_splits()
    
    io.print("part1: ")
    io.println(int.to_string(part1))
    io.print("part2: ")
    io.println(int.to_string(part2))
}

pub fn count_splits(b: List(List(Cell))) -> #(Int, Int) {
    case b {
        [] -> #(0, 0)
        [s, ..b] -> count_splits0(b, s, 0)
    }
}

fn count_splits0(b: List(List(Cell)), s: List(Cell), cnt: Int) -> #(Int, Int) {
    case b {
        [] -> #(
            cnt,
            yielder.from_list(s)
                |> yielder.map(cell_to_int)
                |> yielder.fold(0, int.add)
        )
        [l, ..b] -> {
            let #(c, ns) = split_line(l, s)
            count_splits0(b, ns, cnt + c)
        }
    }
}

fn split_line(l: List(Cell), s: List(Cell)) -> #(Int, List(Cell)) {
    let #(n, r) = split_line0(l, s, [], 0, None)
    #(n, list.reverse(r))
}

fn split_line0(
    l: List(Cell),
    s: List(Cell),
    res: List(Cell),
    cnt: Int,
    set: Cell
) -> #(Int, List(Cell)) {
    let set_cnt = cell_to_int(set)
    case s, l {
        // End case
        [], [] -> #(cnt, res)
        // Splitting laser
        [Laser(n), ..sr], [Split, ..l] ->
            split_line0(l, sr, [None, ..res], cnt + 1, Laser(n))
        // Splitting without laser (no split)
        [_, ..sr], [Split, ..l] -> split_line0(l, sr, [None, ..res], cnt, None) 
        // Aggregating lasers when split on right
        [sv, Laser(n), ..], [lv, Split, ..] -> split_line0(
            list.drop(l, 1),
            list.drop(s, 1),
            [Laser(n + set_cnt + cell_to_int(sv) + cell_to_int(lv)), ..res],
            cnt,
            None
        )
        // Aggregating lasers without split on right.
        [sv, ..sr], [lv, ..l] -> split_line0(
            l,
            sr,
            [int_to_cell(set_cnt + cell_to_int(sv) + cell_to_int(lv)), ..res],
            cnt,
            None
        )
        _, _ -> panic
    }
}

fn parse_line(l: String) -> List(Cell) {
    l |> string.trim() |> string.to_graphemes() |> list.map(parse_cell)
}

fn parse_cell(i: String) -> Cell {
    case i {
        "." -> None
        "^" -> Split
        "S" -> Laser(1)
        _ -> panic
    }
}

fn int_to_cell(n: Int) -> Cell {
    case n {
        0 -> None
        _ -> Laser(n)
    }
}

fn cell_to_int(c: Cell) -> Int {
    case c {
        Laser(n) -> n
        _ -> 0
    }
}
