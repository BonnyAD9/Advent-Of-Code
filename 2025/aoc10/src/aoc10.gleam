import gleam/dict.{type Dict}
import gleam/option.{type Option}
import gleam/pair
import stdin
import gleam/result
import gleam/yielder
import gleam/int
import gleam/list
import gleam/string
import gleam/io

const large = 18446744073709551615

type Machine = #(Int, List(Int), List(Int))
pub type OffMachine = #(Int, List(Int))
type Variable = #(Int, Int) // #(name, value)
type Lin = #(Int, List(Variable))
type Equation = #(Variable, Lin)

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_machine)
        // |> yielder.map(light_button_cnt) // part1
        |> yielder.map(joltage_button_cnt) // part2
        |> yielder.fold(0, int.add)

    io.println(int.to_string(res))
}

pub fn joltage_button_cnt(m: Machine) -> Int {
    let #(_, buttons, joltages) = m
    let lins = prepare_lins(buttons, joltages)
    let cstr = optimize_lins(lins)
    let eqs = gem(lins)
    min_solve(eqs, cstr, buttons)
}

fn min_solve(
    eqs: List(Equation),
    cstr: Dict(Int, #(Int, Int)),
    vars: List(Int)
) -> Int {
    let bound = list.map(eqs, fn(eq) { eq.0 }) |> dict.from_list()
    let unbound = vars
        |> list.filter(fn(v) { !dict.has_key(bound, v) })
        |> list.map(fn(v) { #(
            #(v, 1),
            dict.get(cstr, v) |> result.lazy_unwrap(fn() { panic })
        ) })
    min_solve0(unbound, eqs, dict.new(), large)
}

fn min_solve0(
    vars: List(#(Variable, #(Int, Int))),
    eqs: List(Equation),
    vals: Dict(Int, Int),
    best: Int
) -> Int {
    case vars {
        [] -> {
            case solve_with(eqs, vals) {
                option.None -> best
                option.Some(sol) -> {
                    dict.values(sol)
                        |> list.fold(0, int.add)
                        |> int.min(best)
                }
            }
        }
        [#(_, #(min, max)), ..] if min > max -> best
        [#(#(name, mul), #(min, max)), ..vars] -> {
            let vals2 = dict.insert(vals, name, min)
            let best = min_solve0(vars, eqs, vals2, best)
            let vars2 = [#(#(name, mul), #(min + 1, max)), ..vars]
            min_solve0(vars2, eqs, vals, best)
        }
    }
}

fn solve_with(eqs: List(Equation), vals: Dict(Int, Int))
    -> Option(Dict(Int, Int))
{
    case eqs {
        [] -> option.Some(vals)
        [#(#(name, mul), #(scal, vars)), ..eqs] -> {
            let val = scal + eval(vars, vals)
            let mod = val % mul
            let div = val / mul
            case mod == 0 && div >= 0 {
                True -> {
                    let vals = dict.insert(vals, name, div)
                    solve_with(eqs, vals)
                }
                _ -> option.None
            }
        }
    }
}

fn eval(eq: List(Variable), vals: Dict(Int, Int)) -> Int {
    list.fold(eq, 0, fn(res, var) {
        let #(name, val) = var
        let ev = dict.get(vals, name) |> result.lazy_unwrap(fn() {panic})
        res + ev * val
    })
}

fn gem(l: List(Lin)) -> List(Equation) {
    gem0(l, [])
}

fn gem0(l: List(Lin), res: List(Equation)) -> List(Equation) {
    case l {
        [] -> res
        [#(_, []), ..l] -> gem0(l, res)
        [#(con, [var, ..vars]), ..l] -> {
            let eq = #(var, #(con, negate(vars)))
            let l = gem1(eq, l, [])
            gem0(l, [eq, ..res])
        }
    }
}

fn gem1(eq: Equation, l: List(Lin), res: List(Lin)) -> List(Lin) {
    let #(#(name, mul0), #(scal, subst)) = eq
    let subst = dict.from_list(subst)
    case l {
        [] -> list.reverse(res)
        [#(con, vars), ..l] -> {
            let lin = case list.partition(vars, fn(v) { v.0 == name }) {
                #([], _) -> #(con, vars)
                #([#(_, mul)], vars) -> #(
                    con * mul0 - scal * mul,
                    gem2(vars, subst, mul, mul0)
                )
                _ -> panic
            }
            gem1(eq, l, [lin, ..res])
        }
    }
}

fn gem2(v: List(Variable), subst: Dict(Int, Int), mul: Int, mul0: Int)
    -> List(Variable)
{
    let v = list.map(v, fn(v) { #(v.0, int.multiply(v.1, mul0)) })
        |> dict.from_list()
    subst
        |> dict.map_values(fn(_, v) { v * mul })
        |> dict.combine(v, int.add)
        |> dict.to_list()
        |> list.filter(fn(a) { a.1 != 0 })
}

fn negate(v: List(Variable)) -> List(Variable) {
    list.map(v, fn(a) { #(a.0, -a.1) })
}

fn prepare_lins(buttons: List(Int), joltages: List(Int)) -> List(Lin) {
    joltages
        |> yielder.from_list()
        |> yielder.index()
        |> yielder.map(fn(ji) {
            #(ji.0, lin_joltage_buttons(ji.1, buttons))
        })
        |> yielder.to_list()
}

fn optimize_lins(lins: List(Lin)) -> Dict(Int, #(Int, Int)) {
    optimize_lins0(lins, list.length(lins) * 2, dict.new())
}

fn optimize_lins0(
    lins: List(Lin),
    passes: Int,
    ranges: Dict(Int, #(Int, Int))
) -> Dict(Int, #(Int, Int)) {
    case passes {
        0 -> ranges
        _ -> optimize_lins0(lins, passes - 1, optimize_lins1(lins, ranges))
    }
}

fn optimize_lins1(lins: List(Lin), ranges: Dict(Int, #(Int, Int)))
    -> Dict(Int, #(Int, Int))
{
    case lins {
        [] -> ranges
        [#(tv, btns), ..bins] -> {
            let btns = list.map(btns, pair.first)
            let #(mins, maxs) = btns |> yielder.from_list()
                |> yielder.map(dict.get(ranges, _))
                |> yielder.map(result.unwrap(_, #(0, tv)))
                |> yielder.fold(#(0, 0), fn(s, i) { #(s.0 + i.0, s.1 + i.1) })
            let ranges = optimize_lins2(btns, tv, mins, maxs, ranges)
            optimize_lins1(bins, ranges)
        }
    }
}

fn optimize_lins2(
    btns: List(Int),
    target: Int,
    mins: Int,
    maxs: Int,
    ranges: Dict(Int, #(Int, Int))
) -> Dict(Int, #(Int, Int)) {
    case btns {
        [] -> ranges
        [btn, ..btns] -> {
            let #(bmin, bmax) = dict.get(ranges, btn)
                |> result.unwrap(#(0, target))
            let min = int.max(bmin, target - maxs + bmax)
            let max = int.min(bmax, target - mins + bmin)
            optimize_lins2(
                btns,
                target,
                mins,
                maxs,
                dict.insert(ranges, btn, #(min, max))
            )
        }
    }
}

fn lin_joltage_buttons(i: Int, buttons: List(Int)) -> List(#(Int, Int)) {
    buttons |> list.filter(fn(b) {
        int.bitwise_and(b, int.bitwise_shift_left(1, i)) != 0
    }) |> list.map(fn(a) { #(a, 1) })
}

pub fn light_button_cnt(m: Machine) -> Int {
    light_button_cnt0(#(m.0, m.1), 1, list.length(m.1))
}

fn light_button_cnt0(m: OffMachine, cnt: Int, lim: Int) -> Int {
    case light_button_cnt1(m, cnt, 0) {
        True -> cnt
        False if cnt == lim -> panic
        False -> light_button_cnt0(m, cnt + 1, lim)
    }
}

fn light_button_cnt1(m: OffMachine, cnt: Int, state: Int) -> Bool {
    case m.1 {
        _ if cnt == 0 -> state == m.0
        [] -> False
        [a, ..l] -> light_button_cnt1(
            #(m.0, l),
            cnt - 1,
            int.bitwise_exclusive_or(state, a)
        ) || light_button_cnt1(#(m.0, l), cnt, state)
    }
}

fn parse_machine(s: String) -> Machine {
    let spl = s |> string.trim() |> string.split(" ")
    case spl {
        [lights, ..rest] -> case list.reverse(rest) {
            [joltages, ..buttons] -> {
                #(
                    parse_lights(lights),
                    buttons |> list.map(parse_button),
                    parse_joltages(joltages)
                )
            }
            _ -> panic
        }
        _ -> panic
    }
}

fn parse_joltages(s: String) -> List(Int) {
    string.drop_start(s, 1)
        |> string.drop_end(1)
        |> string.split(",")
        |> list.map(parse_int)
}

fn parse_lights(l: String) -> Int {
    parse_lights0(string.reverse(l), 0)
}

fn parse_lights0(l: String, res: Int) -> Int {
    case l {
        "]" <> l -> parse_lights0(l, res)
        "." <> l -> parse_lights0(l, int.bitwise_shift_left(res, 1))
        "#" <> l -> parse_lights0(
            l,
            int.bitwise_shift_left(res, 1) |> int.bitwise_or(1)
        )
        "[" -> res
        _ -> panic
    }
}

fn parse_button(b: String) -> Int {
    b |> string.drop_start(1)
        |> string.drop_end(1)
        |> string.split(",")
        |> yielder.from_list()
        |> yielder.map(parse_int)
        |> yielder.map(int.bitwise_shift_left(1, _))
        |> yielder.fold(0, int.bitwise_or)
}

fn parse_int(i: String) -> Int {
    int.parse(i) |> result.lazy_unwrap(fn() {panic})
}
