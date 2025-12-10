import stdin
import gleam/result
import gleam/yielder
import gleam/int
import gleam/list
import gleam/string
import gleam/io

type Machine = #(Int, List(Int))

pub fn main() -> Nil {
    let res = stdin.read_lines()
        |> yielder.map(parse_machine)
        |> yielder.map(light_button_cnt)
        |> yielder.fold(0, int.add)

    io.println(int.to_string(res))
}

fn light_button_cnt(m: Machine) -> Int {
    light_button_cnt0(m, 1, list.length(m.1))
}

fn light_button_cnt0(m: Machine, cnt: Int, lim: Int) -> Int {
    case light_button_cnt1(m, cnt, 0) {
        True -> cnt
        False if cnt == lim -> panic
        False -> light_button_cnt0(m, cnt + 1, lim)
    }
}

fn light_button_cnt1(m: Machine, cnt: Int, state: Int) -> Bool {
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
            [_, ..buttons] -> {
                #(parse_lights(lights), buttons |> list.map(parse_button))
            }
            _ -> panic
        }
        _ -> panic
    }
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
