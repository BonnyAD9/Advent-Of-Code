import gleam/float
import gleam/int
import gleam/string
import gleam/result
import gleam/yielder
import stdin
import gleam/io

pub fn main() -> Nil {
    let sum = stdin.read_lines()
        |> yielder.first()
        |> result.unwrap("")
        |> string.split(",")
        |> yielder.from_list
        |> yielder.map(parse_range)
        |> yielder.flat_map(expand_range)
        |> yielder.filter(is_repeated)
        |> yielder.fold(0, int.add)
    
    io.println(int.to_string(sum))
}

pub fn parse_range(s: String) -> #(Int, Int) {
    let #(s, e) = string.split_once(s, "-") |> result.unwrap(#("", ""))
    #(int.parse(s) |> result.unwrap(0), int.parse(e) |> result.unwrap(0))
}

pub fn expand_range(r: #(Int, Int)) -> yielder.Yielder(Int) {
    yielder.range(r.0, r.1)
}

pub fn is_repeated(n: Int) -> Bool {
    let logn = n |> int.to_float() |> float.logarithm() |> result.unwrap(0.)
    let logb = float.logarithm(10.) |> result.unwrap(0.)
    let cnt = 1 + {
        float.divide(logn, logb)
            |> result.unwrap(0.)
            |> float.floor()
            |> float.round
    }
    case cnt % 2 {
        0 -> {
            let mul = int.to_float(cnt / 2) |> int.power(10, _) |> result.unwrap(0.) |> float.round
            n / mul == n % mul
        }
        _ -> False
    }
}
