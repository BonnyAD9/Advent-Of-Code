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

    // TODO: call accesible cnt

    io.println("Hello from aoc04!")
}

fn accessible_cnt(map: Map2D) -> Int {
    // Call 0 variant
}

fn accessible_cnt0(map: Map2D, idx: Int, cnt: Int) -> Int {
    case idx >= bit_array.byte_size() {
        True -> cnt
        False -> {
            let pos = #(idx % map.width, idx / map.width)
            // TODO: count neighborhood
            // TODO: call recursively
        }
    }
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
    case idx.0 < 0 || idx.1 < 0 {
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
