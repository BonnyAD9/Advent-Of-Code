package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"math"
	"os"
	"strings"
)

type vec2 struct {
	x int
	y int
}

const barrier = math.MaxInt

func (s vec2) rotate() vec2 {
	return vec2{-s.y, s.x}
}

func (s vec2) add(v vec2) vec2 {
	return vec2{s.x + v.x, s.y + v.y}
}

func isVisited(v int) bool {
	return v > 0 && v != barrier
}

func main() {
	err := Start()
	if err != nil {
		log.Fatal(err)
	}
}

func Start() error {
	field, pos, dir, e := readMap()
	if e != nil {
		return e
	}

	//res := part1(field, pos, dir)
	res := part2(field, pos, dir)

	fmt.Println(res)

	return nil
}

func part1(field [][]int, pos vec2, dir vec2) int {
	walkMap(field, pos, dir)
	return resetMap(field)
}

func part2(field [][]int, pos vec2, dir vec2) int {
	walkMap(field, pos, dir)
	bars := map[vec2]bool{}
	for y, l := range field {
		for x, t := range l {
			if isVisited(t) {
				bars[vec2{x, y}] = true
				field[y][x] = 0
			}
		}
	}

	res := 0
	for cur := range bars {
		t := at(field, cur)
		if *t == barrier || cur == pos {
			continue
		}
		*t = barrier
		if walkMap(field, pos, dir) {
			res += 1
		}
		resetMap(field)
		*t = 0
	}
	return res
}

func resetMap(field [][]int) int {
	res := 0

	for y, l := range field {
		for x, t := range l {
			if isVisited(t) {
				field[y][x] = 0
				res += 1
			}
		}
	}

	return res
}

func walkMap(field [][]int, pos vec2, dir vec2) bool {
	for at(field, pos) != nil {
		cur := at(field, pos)
		*cur += 1
		if *cur > 4 {
			return true
		}
		newPos := pos.add(dir)
		newTile := at(field, newPos)
		if newTile != nil && *newTile == barrier {
			dir = dir.rotate()
		} else {
			pos = newPos
		}
	}
	return false
}

func readMap() ([][]int, vec2, vec2, error) {
	field := [][]int{}
	pos := vec2{0, 0}
	dir := vec2{0, -1}

	stdin := bufio.NewReader(os.Stdin)
	for {
		l, e := stdin.ReadString('\n')
		if e == io.EOF {
			break
		}
		if e != nil {
			return field, pos, dir, e
		}
		line := []int{}
		for _, c := range strings.TrimSpace(l) {
			if c == '#' {
				line = append(line, barrier)
				continue
			} else if c == '.' {
				line = append(line, 0)
				continue
			}
			pos = vec2{len(line), len(field)}
			line = append(line, 0)
			switch c {
			case '^':
				dir = vec2{0, -1}
			case '>':
				dir = vec2{1, 0}
			case 'v':
				dir = vec2{0, 1}
			case '<':
				dir = vec2{-1, 0}
			}
		}
		field = append(field, line)
	}

	return field, pos, dir, nil
}

func at(field [][]int, pos vec2) *int {
	if pos.y < 0 || pos.x < 0 || pos.y >= len(field) || pos.x >= len(field[pos.y]) {
		return nil
	}
	return &field[pos.y][pos.x]
}
