import gleam/pair
import gleam/int
import gleam/yielder
import stdin
import gleam/list
import gleam/dict.{type Dict}
import gleam/string
import gleam/result
import gleam/io

type Device = #(String, List(String))
type Node = #(Dict(Int, Int), List(String))
type Network = Dict(String, Node)

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_device)
        |> yielder.to_list()
        // |> count_paths("you", "out", []) // part1
        |> count_paths("svr", "out", ["dac", "fft"]) // part2

    io.println(int.to_string(res))
}

fn count_paths(d: List(Device), start: String, end: String, thr: List(String))
    -> Int
{
    let r = list.length(thr) |> int.bitwise_shift_left(1, _) |> int.subtract(1)
    let thr = init_intersections(thr)
    let net = make_network(d)
    let #(_, inps) = dict.get(net, start) |> result.unwrap(#(dict.new(), []))
    let res = dict.insert(net, start, #(dict.from_list([#(
        dict.get(thr, start) |> result.unwrap(0),
        1
    )]), inps))
        |> iterate_network(thr)
        |> dict.get(end)
        |> result.lazy_unwrap(fn() {panic})
    res.0 |> dict.get(r) |> result.unwrap(0)
}

fn init_intersections(thr: List(String)) -> Dict(String, Int) {
    init_intersections0(thr, dict.new(), 1)
}

fn init_intersections0(thr: List(String), res: Dict(String, Int), id: Int)
    -> Dict(String, Int)
{
    case thr {
        [] -> res
        [t, ..thr] -> {
            init_intersections0(
                thr,
                dict.insert(res, t, id),
                int.bitwise_shift_left(id, 1)
            )
        }
    }
}

fn iterate_network(n: Network, thr: Dict(String, Int)) -> Network {
    let #(change, nodes) = iterate_network0(n, thr, dict.keys(n), [], False)
    case change {
        True -> iterate_network(dict.from_list(nodes), thr)
        False -> n
    }
}

fn iterate_network0(
    n: Network,
    thr: Dict(String, Int),
    dl: List(String),
    res: List(#(String, Node)),
    change: Bool
) -> #(Bool, List(#(String, Node))) {
    case dl {
        [] -> #(change, res)
        [d, ..dl] -> {
            let #(cnt, inp) = dict.get(n, d)
                |> result.lazy_unwrap(fn() {panic})
            let tth = dict.get(thr, d) |> result.unwrap(0)
            let in_cnt = list.map(inp, fn(a) {
                dict.get(n, a) |> result.unwrap(#(dict.new(), []))
            }) |> list.fold(dict.new(), fn(s, a) {
                    dict.combine(s, a.0, int.add)
                })
                |> dict.to_list()
                |> list.map(fn(ic) { #(int.bitwise_or(ic.0, tth), ic.1) })
                |> list.group(pair.first)
                |> dict.map_values(fn(_, v) {
                    list.map(v, pair.second) |> int.sum
                })
                |> dict.combine(cnt, int.max)
            let change = change || in_cnt != cnt
            iterate_network0(n, thr, dl, [#(d, #(in_cnt, inp)), ..res], change)
        }
    }
}

fn make_network(d: List(Device)) -> Network {
    make_network0(d, dict.new())
        |> dict.map_values(fn(_, a) { #(dict.new(), a) })
}

fn make_network0(dl: List(Device), res: Dict(String, List(String)))
    -> Dict(String, List(String))
{
    case dl {
        [] -> res
        [#(name, out), ..dl] -> {
            let net = out
                |> list.map(fn(o) { #(o, [name]) })
                |> dict.from_list()
                |> dict.combine(res, list.append)
            make_network0(dl, net)
        }
    }
}

fn parse_device(s: String) -> Device {
    let #(name, outs) = string.split_once(s, ":")
        |> result.lazy_unwrap(fn() {panic})
    #(
        string.trim(name),
        string.trim(outs) |> string.split(" ")
    )
}
