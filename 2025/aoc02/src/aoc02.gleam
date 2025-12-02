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
        // |> yielder.filter(is_repeated(_, 2)) // part1
        |> yielder.filter(is_repeated_any) // part2
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

pub fn is_repeated_any(n: Int) -> Bool {
    let cnt = count_digits(n, 10.)
    is_repeated_any0(n, cnt, cnt)
}

pub fn is_repeated_any0(n: Int, cnt: Int, rep: Int) -> Bool {
    rep >= 2 && { is_repeated0(n, cnt, rep) || is_repeated_any0(n, cnt, rep - 1) }
}

pub fn is_repeated(n: Int, rep: Int) -> Bool {
    is_repeated0(n, count_digits(n, 10.), rep)
}

pub fn is_repeated0(n: Int, cnt: Int, rep: Int) -> Bool {
    case cnt % rep {
        0 -> {
            let mul = int.to_float(cnt / rep)
                |> int.power(10, _)
                |> result.unwrap(0.)
                |> float.round
            is_repeated1(n, mul, n % mul)
        }
        _ -> False
    }
}

pub fn is_repeated1(n: Int, mul: Int, pat: Int) -> Bool {
    let div = n / mul
    let mod = n % mul
    case n {
        0 -> True
        _ -> mod == pat && is_repeated1(div, mul, pat)
    }
}

pub fn count_digits(n: Int, base: Float) -> Int {
    case n == 0 {
        True -> 1
        False -> {
            let logn = n |> int.to_float()
                |> float.logarithm()
                |> result.unwrap(0.)
            let logb = float.logarithm(base) |> result.unwrap(0.)
            1 + {
                float.divide(logn, logb)
                    |> result.unwrap(0.)
                    |> float.floor()
                    |> float.round
            }
        }
    }
}
