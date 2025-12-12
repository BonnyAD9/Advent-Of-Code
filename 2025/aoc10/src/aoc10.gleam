import gleam/dict.{type Dict}
import gleam/pair
import stdin
import gleam/result
import gleam/yielder
import gleam/int
import gleam/list
import gleam/string
import gleam/io

type Machine = #(Int, List(Int), List(Int))
pub type OffMachine = #(Int, List(Int))
type Joltage = #(Int, Int) // #(value, id)
type Bin = #(Joltage, List(Int))

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_machine)
        // |> yielder.map(light_button_cnt)
        |> yielder.map(joltage_button_cnt)
        |> yielder.fold(0, int.add)

    io.println(int.to_string(res))
}

pub fn joltage_button_cnt(m: Machine) -> Int {
    let #(_, buttons, joltages) = m
    let buttons = sort_buttons(buttons)
    let bins = prepare_bins(buttons, joltages)
    let joltages = list.map(bins, fn(b) { #(0, b.0.1) })
    let res = case bins {
        [bin, ..bins] -> joltage_button_cnt0(bin, bins, joltages, 0, 0, False)
        _ -> panic
    }
    io.println(int.to_string(res))
    res
}

fn joltage_button_cnt0(bin: Bin, bins: List(Bin), joltages: List(Joltage), cnt: Int, idx: Int, take: Bool) -> Int {
    let #(#(tj, _), buttons) = bin
    case buttons, bins, list.drop(joltages, idx) {
        [], [], [#(cj, _), ..] if cj == tj -> cnt
        [], [], _ -> -1
        _, [bin, ..bins], [#(cj, _), ..] if cj == tj -> {
            joltage_button_cnt0(bin, bins, joltages, cnt, idx + 1, False)
        }
        [], [_, ..], [_, ..] -> -1
        [_, ..], _, [#(cj, _), ..] if cj > tj -> -1
        [button], [bin, ..bins], [#(cj, _), ..] -> {
            let pc = tj - cj
            joltage_button_cnt0(bin, bins, press_button_j(button, pc, joltages), cnt + pc, idx + 1, False)
        }
        [button, ..buttons], _, _ -> {
            let #(joltages, cnt) = case take {
                True -> #(press_button_j(button, 1, joltages), cnt + 1)
                False -> #(joltages, cnt)
            }
            let res = joltage_button_cnt0(#(bin.0, buttons), bins, joltages, cnt, idx, False)
            case res == -1 {
                True -> joltage_button_cnt0(bin, bins, joltages, cnt, idx, True)
                False -> res
            }
        } // 7, 4, 5, 3
        _, _, _ -> panic
    }
}

fn press_button_j(button: Int, cnt: Int, joltages: List(Joltage)) -> List(Joltage) {
    press_button_j0(button, cnt, joltages, []) |> list.reverse()
}

fn press_button_j0(button: Int, cnt: Int, joltages: List(Joltage), res: List(Joltage)) -> List(Joltage) {
    case joltages {
        [] -> res
        [#(jv, ji), ..joltages] -> {
            let jv = case int.bitwise_shift_left(1, ji) |> int.bitwise_and(button) != 0 {
                True -> jv + cnt
                False -> jv
            }
            press_button_j0(
                button,
                cnt,
                joltages,
                [#(jv, ji), ..res]
            )
        }
    }
}

fn sort_buttons(buttons: List(Int)) -> List(Int) {
    list.map(buttons, fn(b) { #(count_ones(b), b) })
        |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
        |> list.map(pair.second)
}

fn prepare_bins(buttons: List(Int), joltages: List(Int)) -> List(Bin) {
    joltages
        |> yielder.from_list()
        |> yielder.index()
        |> yielder.map(fn(ji) {
            #(ji, bin_joltage(ji.1, buttons))
        })
        |> yielder.map(fn(jb) { #(list.length(jb.1), jb) })
        |> yielder.to_list()
        |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
        |> list.map(pair.second)
        |> filter_bin_buttons()
}

fn filter_bin_buttons(bins: List(Bin)) -> List(Bin) {
    filter_bin_buttons0(bins, [], dict.new())
        |> list.reverse()
}

fn filter_bin_buttons0(bins: List(Bin), res: List(Bin), used: Dict(Int, Bool)) -> List(Bin) {
    case bins {
        [] -> res
        [b, ..bins] -> {
            let buts = list.filter(b.1, fn(b) { !dict.has_key(used, b) })
            let used = list.map(b.1, fn(a) { #(a, True) }) |> dict.from_list() |> dict.merge(used)
            filter_bin_buttons0(bins, [#(b.0, buts), ..res], used)
        }
    }
}

fn bin_joltage(i: Int, buttons: List(Int)) -> List(Int) {
    buttons |> list.filter(fn(b) {
        int.bitwise_and(b, int.bitwise_shift_left(1, i)) != 0
    })
}

fn count_ones(n: Int) -> Int {
    count_ones0(n, 0)
}

fn count_ones0(n: Int, res: Int) -> Int {
    case n, int.bitwise_and(n, 1) == 1 {
        0, _ -> res
        _, False -> count_ones0(int.bitwise_shift_right(n, 1), res)
        _, True -> count_ones0(int.bitwise_shift_right(n, 1), res + 1)
    }
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

// fn bin_to_string(b: Bin) -> String {
//     joltage_to_string(b.0) <> buttons_to_string(b.1)
// }
// 
// fn buttons_to_string(b: List(Int)) -> String {
//     "[" <> { list.map(b, int.to_base2) |> string.join(",") } <> "]"
// }
// 
// fn joltage_to_string(j: Joltage) -> String {
//     int.to_string(j.0) <> "@" <> int.to_string(j.1)
// }
