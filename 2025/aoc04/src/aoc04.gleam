import gleam/int
import gleam/list
import gleam/result
import gleam/bit_array
import gleam/yielder
import gleam/string
import stdin
import gleam/io

type Map2D {
    Map2D(data: BitArray, width: Int)
}

const roll: Int = 64

pub fn main() -> Nil {
    let lines = stdin.read_lines()
        |> yielder.map(string.trim)
        |> yielder.to_list()
    
    let res = accessible_cnt(from_lines(lines))
    io.println(int.to_string(res))
}

fn accessible_cnt(map: Map2D) -> Int {
    accessible_cnt0(map, 0, 0)
}

fn accessible_cnt0(map: Map2D, idx: Int, cnt: Int) -> Int {
    case idx >= bit_array.byte_size(map.data) {
        True -> cnt
        False -> {
            let pos = #(idx % map.width, idx / map.width)
            let ncnt = neighborhood(map, pos) |> list.count(is_roll)
            let cnt2 = case is_roll(at(map, pos)) && ncnt < 4 {
                True -> cnt + 1
                False -> cnt
            }
            accessible_cnt0(map, idx + 1, cnt2)
        }
    }
}

fn is_roll(a: Int) -> Bool {
    a == roll
}

fn from_lines(lines: List(String)) -> Map2D {
    case lines {
        [] -> Map2D(<<>>, 0)
        [l, ..] -> lines
            |> string.join("")
            |> bit_array.from_string()
            |> Map2D(string.byte_size(l))
    }
}

fn at(map: Map2D, idx: #(Int, Int)) -> Int {
    case idx.0 < 0 || idx.1 < 0 || idx.0 >= map.width {
        True -> 0
        False -> {
            let slice = bit_array.slice(map.data, idx.1 * map.width + idx.0, 1) |> result.unwrap(<<0>>)
            case slice {
                <<n>> -> n
                _ -> panic
            }
        }
    }
}

fn neighborhood(map: Map2D, idx: #(Int, Int)) -> List(Int) {
    let #(x, y) = idx
    [
        at(map, #(x - 1, y - 1)), at(map, #(x, y - 1)), at(map, #(x + 1, y - 1)),
        at(map, #(x - 1, y)), at(map, #(x + 1, y)),
        at(map, #(x - 1, y + 1)), at(map, #(x, y + 1)), at(map, #(x + 1, y + 1))
    ]
}
