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
    
    let part1 = accessible_cnt(from_lines(lines))
    let part2 = remove_accesible_cnt(from_lines(lines))
    
    io.print("part1: ")
    io.println(int.to_string(part1))
    io.print("part2: ")
    io.println(int.to_string(part2))
}

fn remove_accesible_cnt(map: Map2D) -> Int {
    remove_accesible_cnt0(map, 0)
}

fn remove_accesible_cnt0(map: Map2D, sum: Int) -> Int {
    let #(cnt, map2) = remove_accesible_cnt1(map, 0, 0)
    case cnt {
        0 -> sum
        _ -> remove_accesible_cnt0(map2, sum + cnt)
    }
}

fn remove_accesible_cnt1(map: Map2D, idx: Int, cnt: Int) -> #(Int, Map2D) {
    case idx >= bit_array.byte_size(map.data) {
        True -> #(cnt, map)
        False -> {
            let pos = #(idx % map.width, idx / map.width)
            let ncnt = neighborhood(map, pos) |> list.count(is_roll)
            let #(cnt2, map2) = case is_roll(at(map, pos)) && ncnt < 4 {
                True -> #(cnt + 1, set_at(map, pos, 0))
                False -> #(cnt, map)
            }
            remove_accesible_cnt1(map2, idx + 1, cnt2)
        }
    }
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
            let slice = bit_array.slice(map.data, idx.1 * map.width + idx.0, 1)
                |> result.unwrap(<<0>>)
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

fn set_at(map: Map2D, idx: #(Int, Int), val: Int) -> Map2D {
    let pos = idx.1 * map.width + idx.0
    let len = bit_array.byte_size(map.data)
    let half2 =  bit_array.slice(
        map.data,
        pos + 1,
        int.max(0, len - pos - 1)
    ) |> result.unwrap(<<>>)
    let data = bit_array.slice(map.data, 0, pos)
        |> result.unwrap(<<>>)
        |> bit_array.append(<<val>>)
        |> bit_array.append(half2)
    Map2D(data, map.width)
}
