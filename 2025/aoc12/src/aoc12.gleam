import gleam/yielder
import stdin
import gleam/string
import gleam/result
import gleam/int
import gleam/list
import gleam/io

type Tree = #(Int, Int, List(Int))
// how much spaces each shape contributes on average (occupied spaces + 1)
const weights = [8, 8, 7, 6, 8, 8]

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.filter(string.contains(_, "x"))
        |> yielder.map(parse_tree)
        |> yielder.filter(tree_fits)
        |> yielder.fold(0, fn(a, _) { a + 1 })
    
    io.println(int.to_string(res))
}

fn tree_fits(t: Tree) -> Bool {
    t.0 * t.1 > dot(t.2, weights) // this rough estimation is precise enough :)
}

fn parse_tree(s: String) -> Tree {
    let #(wh, c) = string.split_once(s, ":")
        |> result.lazy_unwrap(fn() { panic })
    let #(w, h) = string.split_once(wh, "x")
        |> result.lazy_unwrap(fn() { panic })
    let cnts = string.trim(c)
        |> string.split(" ")
        |> list.try_map(int.parse)
        |> result.lazy_unwrap(fn() { panic })
    #(
        int.parse(w) |> result.lazy_unwrap(fn() { panic }),
        int.parse(h) |> result.lazy_unwrap(fn() { panic }),
        cnts
    )
}

fn dot(a: List(Int), b: List(Int)) -> Int {
    list.zip(a, b) |> list.map(fn(a) { a.0 * a.1 }) |> list.fold(0, int.add)
}
