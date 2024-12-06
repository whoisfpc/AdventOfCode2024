package day06

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

Direction :: enum {
	Up,
	Down,
	Left,
	Right,
}
Direction_Set :: bit_set[Direction]

Direction_Move := [Direction][2]int {
	.Up    = {-1, 0},
	.Down  = {+1, 0},
	.Left  = {0, -1},
	.Right = {0, +1},
}

next_dir :: proc(dir: Direction) -> Direction {
	switch dir {
	case .Up:
		return .Right
	case .Right:
		return .Down
	case .Down:
		return .Left
	case .Left:
		return .Up
	}
	unreachable()
}

part1 :: proc(input: [][]u8) -> int {
	ans := 0
	height := len(input)
	width := len(input[0])

	pass_map := make([][]Direction_Set, height)
	for &line in pass_map {
		line = make([]Direction_Set, width)
	}

	defer {
		for line in pass_map {
			delete(line)
		}
		delete(pass_map)
	}

	start := [2]int{-1, -1}
	for line, i in input {
		for c, j in line {
			if c == '^' {
				start.x = i
				start.y = j
				break
			}
		}
	}

	assert(start != [2]int{-1, -1})
	pos := start
	dir := Direction.Up

	for {
		if dir in pass_map[pos.x][pos.y] {
			break
		}
		pass_map[pos.x][pos.y] += {dir}
		next := pos + Direction_Move[dir]
		if next.x < 0 || next.x >= height || next.y < 0 || next.y >= width {
			break
		}
		if input[next.x][next.y] == '#' {
			dir = next_dir(dir)
		} else {
			pos = next
		}
	}

	for line in pass_map {
		for c in line {
			if card(c) > 0 {
				ans += 1
			}
		}
	}
	return ans
}

reset_pass_map :: proc(pass_map: [][]Direction_Set) {
	for line in pass_map {
		for &c in line {
			c = {}
		}
	}
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	height := len(input)
	width := len(input[0])

	pass_map := make([][]Direction_Set, height)
	for &line in pass_map {
		line = make([]Direction_Set, width)
	}

	defer {
		for line in pass_map {
			delete(line)
		}
		delete(pass_map)
	}

	start := [2]int{-1, -1}
	for line, i in input {
		for c, j in line {
			if c == '^' {
				start.x = i
				start.y = j
				break
			}
		}
	}

	assert(start != [2]int{-1, -1})
	for i in 0 ..< height {
		for j in 0 ..< width {
			if input[i][j] == '#' || input[i][j] == '^' {
				continue
			}
			reset_pass_map(pass_map)
			pos := start
			dir := Direction.Up

			for {
				if dir in pass_map[pos.x][pos.y] {
					ans += 1
					break
				}
				pass_map[pos.x][pos.y] += {dir}
				next := pos + Direction_Move[dir]
				if next.x < 0 || next.x >= height || next.y < 0 || next.y >= width {
					break
				}
				if input[next.x][next.y] == '#' || (next.x == i && next.y == j) {
					dir = next_dir(dir)
				} else {
					pos = next
				}
			}
		}
	}

	return ans
}
