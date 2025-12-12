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
type BtnRange = #(Int, Int, Int) // #(button, min, max)
type OptBin = #(Joltage, List(BtnRange))

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
    io.println(list.map(bins, opt_bin_to_string) |> string.join("\n"))
    let res = case bins {
        [bin, ..bins] -> joltage_button_cnt0(bin, bins, joltages, 0, 0)
        _ -> panic
    }
    io.println(int.to_string(res))
    io.println("")
    res
}

fn joltage_button_cnt0(bin: OptBin, bins: List(OptBin), joltages: List(Joltage), cnt: Int, idx: Int) -> Int {
    let #(#(tj, _), buttons) = bin
    case buttons, bins, list.drop(joltages, idx) {
        [], [], [#(cj, _), ..] if cj == tj -> cnt
        [], [], _ -> -1
        _, [bin, ..bins], [#(cj, _), ..] if cj == tj -> {
            joltage_button_cnt0(bin, bins, joltages, cnt, idx + 1)
        }
        [], [_, ..], [_, ..] -> -1
        [_, ..], _, [#(cj, _), ..] if cj > tj -> -1
        [#(btn, min, max)], [bin, ..bins], [#(cj, _), ..] -> {
            let pc = tj - cj
            case pc < min || pc > max {
                True -> -1
                False -> joltage_button_cnt0(bin, bins, press_button_j(btn, pc, joltages), cnt + pc, idx + 1)
            }
        }
        [#(btn, min, max), ..buttons], _, _ -> {
            let #(joltages, cnt, pc) = case min != 0 {
                True -> {
                    let pc = int.max(min, 1)
                    #(press_button_j(btn, pc, joltages), cnt + pc, pc)
                }
                False -> #(joltages, cnt, 0)
            }
            let res = joltage_button_cnt0(#(bin.0, buttons), bins, joltages, cnt, idx)
            case res == -1 {
                True -> joltage_button_cnt0(#(bin.0, [#(btn, 1, max - pc), ..buttons]), bins, joltages, cnt, idx)
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

fn prepare_bins(buttons: List(Int), joltages: List(Int)) -> List(OptBin) {
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
        |> optimize_bins()
        |> filter_bin_buttons()
}

fn optimize_bins(bins: List(Bin)) -> List(OptBin) {
    let ranges = optimize_bins0(bins, list.length(bins) * 2, dict.new())
    list.map(bins, fn(bin) {
        #(bin.0, list.map(bin.1, fn(b) {
            let #(min, max) = dict.get(ranges, b) |> result.lazy_unwrap(fn() {panic})
            #(b, min, max)
        }))
    })
}

fn optimize_bins0(bins: List(Bin), passes: Int, ranges: Dict(Int, #(Int, Int))) -> Dict(Int, #(Int, Int)) {
    case passes {
        0 -> ranges
        _ -> optimize_bins0(bins, passes - 1, optimize_bins1(bins, ranges))
    }
}

fn optimize_bins1(bins: List(Bin), ranges: Dict(Int, #(Int, Int))) -> Dict(Int, #(Int, Int)) {
    case bins {
        [] -> ranges
        [#(#(tv, _), btns), ..bins] -> {
            let #(mins, maxs) = btns |> yielder.from_list()
                |> yielder.map(dict.get(ranges, _))
                |> yielder.map(result.unwrap(_, #(0, tv)))
                |> yielder.fold(#(0, 0), fn(s, i) { #(s.0 + i.0, s.1 + i.1) })
            let ranges = optimize_bins2(btns, tv, mins, maxs, ranges)
            optimize_bins1(bins, ranges)
        }
    }
}

fn optimize_bins2(btns: List(Int), target: Int, mins: Int, maxs: Int, ranges: Dict(Int, #(Int, Int))) -> Dict(Int, #(Int, Int)) {
    case btns {
        [] -> ranges
        [btn, ..btns] -> {
            let #(bmin, bmax) = dict.get(ranges, btn) |> result.unwrap(#(0, target))
            let min = int.max(bmin, target - maxs + bmax)
            let max = int.min(bmax, target - mins + bmin)
            optimize_bins2(btns, target, mins, maxs, dict.insert(ranges, btn, #(min, max)))
        }
    }
}

fn filter_bin_buttons(bins: List(OptBin)) -> List(OptBin) {
    filter_bin_buttons0(bins, [], dict.new())
        |> list.reverse()
}

fn filter_bin_buttons0(bins: List(OptBin), res: List(OptBin), used: Dict(Int, Bool)) -> List(OptBin) {
    case bins {
        [] -> res
        [b, ..bins] -> {
            let buts = list.filter(b.1, fn(b) { !dict.has_key(used, b.0) })
            let used = list.map(b.1, fn(a) { #(a.0, True) }) |> dict.from_list() |> dict.merge(used)
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

// fn opt_bins_to_string(b: List(OptBin)) -> String {
//     "[" <> { list.map(b, opt_bin_to_string) |> string.join(",") } <> "]"
// }

// fn bin_to_string(b: Bin) -> String {
//     joltage_to_string(b.0) <> buttons_to_string(b.1)
// }

fn opt_bin_to_string(b: OptBin) -> String {
    joltage_to_string(b.0) <> btn_ranges_to_string(b.1)
}

fn btn_ranges_to_string(b: List(BtnRange)) -> String {
    "[" <> { list.map(b, btn_range_to_string) |> string.join(",") } <> "]"
}

fn btn_range_to_string(b: BtnRange) -> String {
    int.to_base2(b.0) <> "@" <> int.to_string(b.1) <> ".." <> int.to_string(b.2)
}

// fn buttons_to_string(b: List(Int)) -> String {
//     "[" <> { list.map(b, int.to_base2) |> string.join(",") } <> "]"
// }

fn joltage_to_string(j: Joltage) -> String {
    int.to_string(j.0) <> "@" <> int.to_string(j.1)
}
