#!/usr/bin/awk -f

BEGIN {
    res = 0;
    enabled = 1;
}

function part1(str) {
    reg = "mul\\(([0-9]{1,3}),([0-9]{1,3})\\)";
    mat = match(str, reg, a);
    while (mat != 0) {
        res += a[1] * a[2];
        str = substr(str, RSTART + RLENGTH);
        mat = match(str, reg, a);
    }
}

function part2(str) {
    reg = "mul\\(([0-9]{1,3}),([0-9]{1,3})\\)|do\\(\\)|don't\\(\\)";
    mat = match(str, reg, a);
    while (mat != 0) {
        if (a[0] == "do()") {
            enabled = 1;
        } else if (a[0] == "don't()") {
            enabled = false;
        } else if (enabled) {
            res += a[1] * a[2];
        }
        str = substr(str, RSTART + RLENGTH);
        mat = match(str, reg, a);
    }
}

{
    #part1($0);
    part2($0);
}

END {
    print res
}
