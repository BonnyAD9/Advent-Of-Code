import gleam/int
import gleam/yielder
import stdin
import gleam/list
import gleam/dict.{type Dict}
import gleam/string
import gleam/result
import gleam/io

type Device = #(String, List(String))
type Node = #(Int, List(String))
type Network = Dict(String, Node)

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_device)
        |> yielder.to_list()
        |> count_paths("you", "out")

    io.println(int.to_string(res))
}

fn count_paths(d: List(Device), start: String, end: String) -> Int {
    let net = make_network(d)
    let #(_, inps) = dict.get(net, start) |> result.lazy_unwrap(fn() {panic})
    let res = dict.insert(net, start, #(1, inps))
        |> iterate_network()
        |> dict.get(end)
        |> result.lazy_unwrap(fn() {panic})
    res.0
}

fn iterate_network(n: Network) -> Network {
    // io.println(dict.to_list(n) |> list.map(labeled_node_to_string) |> string.join("\n") <> "\n")
    let #(change, nodes) = iterate_network0(n, dict.keys(n), [], False)
    case change {
        True -> iterate_network(dict.from_list(nodes))
        False -> n
    }
}

fn iterate_network0(n: Network, dl: List(String), res: List(#(String, Node)), change: Bool) -> #(Bool, List(#(String, Node))) {
    case dl {
        [] -> #(change, res)
        [d, ..dl] -> {
            let #(cnt, inp) = dict.get(n, d) |> result.lazy_unwrap(fn() {panic})
            let in_cnt = list.map(inp, fn(a) { dict.get(n, a) |> result.unwrap(#(0, [])) })
                |> list.fold(0, fn(s, a) { s + a.0 })
                |> int.max(cnt)
            let change = change || in_cnt != cnt
            iterate_network0(n, dl, [#(d, #(in_cnt, inp)), ..res], change)
        }
    }
}

fn make_network(d: List(Device)) -> Network {
    make_network0(d, dict.new()) |> dict.map_values(fn(_, a) { #(0, a) })
}

fn make_network0(dl: List(Device), res: Dict(String, List(String))) -> Dict(String, List(String)) {
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
    let #(name, outs) = string.split_once(s, ":") |> result.lazy_unwrap(fn() {panic})
    #(
        string.trim(name),
        string.trim(outs) |> string.split(" ")
    )
}

// fn labeled_node_to_string(n: #(String, Node)) -> String {
//     n.0 <> ": " <> node_to_string(n.1)
// }

// fn node_to_string(n: Node) -> String {
//     int.to_string(n.0) <> "<-[" <> string.join(n.1, " ") <> "]"
// }
