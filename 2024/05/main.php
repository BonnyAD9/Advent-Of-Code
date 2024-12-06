<?php

$rules = [];

while (true) {
    $rule = fscanf(STDIN, " %D|%D");
    if (!$rule) {
        break;
    }
    array_push($rules, $rule);
}

//$res = part1($rules);
$res = part2($rules);

echo "$res\n";

function part1(array $rules): int {
    $res = 0;

    while (true) {
        $line = fgets(STDIN);
        if (!$line) {
            break;
        }
        $pages =
            array_map(function($i) { return (int)$i; }, explode(",", $line));
        if (is_sorted($rules, $pages)) {
            $res += $pages[count($pages) / 2];
        }
    }

    return $res;
}

function part2(array $rules): int {
    $res = 0;

    while (true) {
        $line = fgets(STDIN);
        if (!$line) {
            break;
        }
        $pages = explode(",", $line);
        if (is_sorted($rules, $pages)) {
            continue;
        }
        if (fix_sort($rules, $pages)) {
            $res += $pages[count($pages) / 2];
        } else {
            echo "unfixable: $line";
        }
    }

    return $res;
}

function is_sorted(array $rules, array $pages): bool {
    foreach ($rules as $rule) {
        $f = array_search($rule[0], $pages);
        $s = array_search($rule[1], $pages);
        if ($f !== false && $s !== false && $f > $s) {
            return false;
        }
    }
    return true;
}

function fix_sort(array $rules, array &$pages): bool {
    $change = true;
    $cnt = 0;
    while ($change) {
        if ($cnt > count($pages)) {
            return false;
        }
        $change = false;
        foreach ($rules as $rule) {
            $f = array_search($rule[0], $pages);
            $s = array_search($rule[1], $pages);
            if ($f === false || $s === false || $f < $s) {
                continue;
            }
            $change = true;
            swap($pages[$f], $pages[$s]);
        }
        ++$cnt;
    }
    return true;
}

function swap(mixed &$a, mixed &$b) {
    $h = $a;
    $a = $b;
    $b = $h;
}
