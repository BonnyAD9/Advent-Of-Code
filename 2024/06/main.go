package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

type vec2 struct {
	x int
	y int
}

type Tile int8

const (
	Unvisited Tile = iota
	VisitedUp
	VisitedRight
	VisitedDown
	VisitedLeft
	Barier
)

func (s vec2) rotate() vec2 {
	return vec2{-s.y, s.x}
}

func (s vec2) add(v vec2) vec2 {
	return vec2{s.x + v.x, s.y + v.y}
}

func (s vec2) toTile() Tile {
	switch s {
	case vec2{-1, 0}:
		return VisitedUp
	case vec2{0, 1}:
		return VisitedRight
	case vec2{1, 0}:
		return VisitedDown
	case vec2{0, -1}:
		return VisitedLeft
	default:
		return VisitedUp
	}
}

func (s Tile) isVisited() bool {
	return s == VisitedUp || s == VisitedDown || s == VisitedRight || s == VisitedLeft
}

func main() {
	err := Start()
	if err != nil {
		log.Fatal(err)
	}
}

func Start() error {
	field, pos, dir, e := readMap();
	if e != nil {
		return e;
	}

	//res := part1(field, pos, dir)
	res := part2(field, pos, dir)

	fmt.Println(res)

	return nil
}

func part1(field [][]Tile, pos vec2, dir vec2) int {
	walkMap(field, pos, dir)
	return resetMap(field)
}

func part2(field [][]Tile, pos vec2, dir vec2) int {
	res := 0;
	for y, l := range field {
		for x, t := range l {
			if t == Barier || (pos == vec2{x, y}) {
				continue
			}
			field[y][x] = Barier;
			if walkMap(field, pos, dir) {
				res += 1;
			}
			resetMap(field)
			field[y][x] = Unvisited
		}
	}
	return res
}

func resetMap(field [][]Tile) int {
	res := 0;

	for y, l := range field {
		for x, t := range l {
			if t.isVisited() {
				field[y][x] = Unvisited
				res += 1
			}
		}
	}

	return res
}

func walkMap(field [][]Tile, pos vec2, dir vec2) bool {
	cnt := 0;
	maxCnt := len(field) * len(field[0]) * 4
	for at(field, pos) != nil {
		if *at(field, pos) == dir.toTile() || cnt > maxCnt {
			return true
		}
		*at(field, pos) = dir.toTile()
		newPos := pos.add(dir)
		newTile := at(field, newPos)
		if newTile != nil && *newTile == Barier {
			dir = dir.rotate()
		} else {
			pos = newPos
		}
		cnt += 1
	}
	return false
}

func readMap() ([][]Tile, vec2, vec2, error) {
	field := [][]Tile{}
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
		line := []Tile{}
		for _, c := range strings.TrimSpace(l) {
			if c == '#' {
				line = append(line, Barier)
				continue
			} else if c == '.' {
				line = append(line, Unvisited)
				continue
			}
			pos = vec2{len(line), len(field)}
			line = append(line, Unvisited)
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

func at(field [][]Tile, pos vec2) *Tile {
	if pos.y < 0 || pos.x < 0 || pos.y >= len(field) || pos.x >= len(field[pos.y]) {
		return nil
	}
	return &field[pos.y][pos.x]
}
