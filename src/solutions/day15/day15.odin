package day15

import "core:fmt"
import "core:image"
import "core:image/bmp"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:text/regex"

V2 :: [2]int

Move := [4][2]int {
	0 = {-1, 0},
	1 = {+1, 0},
	2 = {0, -1},
	3 = {0, +1},
}

make_2d :: proc(height, width: int, $E: typeid) -> [][]E {
	s2 := make([][]E, height)
	for &line in s2 {
		line = make([]E, width)
	}
	return s2
}

destroy_2d :: proc(s2: $T/[][]$E) {
	for line in s2 {
		delete(line)
	}
	delete(s2)
}

find_width_height :: proc(input: [][]u8) -> (width, height: int) {
	width = len(input[0])
	for i in 0 ..< len(input) {
		if len(input[i]) == 0 {
			height = i
			break
		}
	}
	return width, height
}

get_move :: proc(c: u8) -> [2]int {
	switch c {
	case '^':
		return Move[0]
	case 'v':
		return Move[1]
	case '<':
		return Move[2]
	case '>':
		return Move[3]
	case:
		unreachable()
	}
}

print_house_map :: proc(house_map: [][]u8, pos: V2) {
	for line, i in house_map {
		for c, j in line {
			if pos.x == i && pos.y == j {
				fmt.print('@')
			} else {
				fmt.print(rune(c))
			}
		}
		fmt.println()
	}
}

part1 :: proc(input: [][]u8) -> int {
	ans := 0
	width, height := find_width_height(input)
	house_map := make_2d(height, width, u8)
	defer destroy_2d(house_map)

	start: V2
	for i in 0 ..< height {
		for c, j in input[i] {
			if c == '@' {
				start = V2{i, j}
				house_map[i][j] = '.'
			} else {
				house_map[i][j] = c
			}
		}
	}

	for i in (height + 1) ..< len(input) {
		for c in input[i] {
			delta := get_move(c)
			next := start + delta
			next_c := house_map[next.x][next.y]
			if next_c == '#' {
				// do nothing
			} else if next_c == '.' {
				start = next
			} else {
				assert(next_c == 'O')
				if try_move_box(house_map, next, delta) {
					start = next
				}
			}
		}
	}
	// print_house_map(house_map, start)
	for line, i in house_map {
		for c, j in line {
			if c == 'O' {
				ans += i * 100 + j
			}
		}
	}
	return ans
}

try_move_box :: proc(house_map: [][]u8, box: V2, delta: V2) -> bool {
	assert(house_map[box.x][box.y] == 'O')
	next := box + delta
	if house_map[next.x][next.y] == '.' {
		house_map[box.x][box.y] = '.'
		house_map[next.x][next.y] = 'O'
		return true
	} else if house_map[next.x][next.y] == '#' {
		return false
	} else {
		assert(house_map[next.x][next.y] == 'O')
		if try_move_box(house_map, next, delta) {
			house_map[box.x][box.y] = '.'
			house_map[next.x][next.y] = 'O'
			return true
		}
		return false
	}
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	width, height := find_width_height(input)
	house_map := make_2d(height, width * 2, u8)
	defer destroy_2d(house_map)

	start: V2
	for i in 0 ..< height {
		for c, j in input[i] {
			if c == '@' {
				start = V2{i, j * 2}
				house_map[i][j * 2] = '.'
				house_map[i][j * 2 + 1] = '.'
			} else if c == 'O' {
				house_map[i][j * 2] = '['
				house_map[i][j * 2 + 1] = ']'
			} else {
				house_map[i][j * 2] = c
				house_map[i][j * 2 + 1] = c
			}
		}
	}

	for i in (height + 1) ..< len(input) {
		for c in input[i] {
			delta := get_move(c)
			next := start + delta
			next_c := house_map[next.x][next.y]
			if next_c == '#' {
				// do nothing
			} else if next_c == '.' {
				start = next
			} else {
				assert(next_c == '[' || next_c == ']')
				if try_move_wide_box(house_map, next, delta) {
					start = next
				}
			}
			// print_house_map(house_map, start)
		}
	}
	// print_house_map(house_map, start)
	for line, i in house_map {
		for c, j in line {
			if c == '[' {
				ans += i * 100 + j
			}
		}
	}
	return ans
}

try_move_wide_box :: proc(house_map: [][]u8, box: V2, delta: V2) -> bool {
	if delta.x == 0 {
		return try_move_wide_box_lr(house_map, box, delta)
	} else {
		return try_move_wide_box_ud(house_map, box, delta)
	}
}

try_move_wide_box_lr :: proc(house_map: [][]u8, box: V2, delta: V2) -> bool {
	box_c := house_map[box.x][box.y]
	assert(box_c == '[' || box_c == ']')
	next := box + delta
	if house_map[next.x][next.y] == '.' {
		house_map[box.x][box.y] = '.'
		house_map[next.x][next.y] = box_c
		return true
	} else if house_map[next.x][next.y] == '#' {
		return false
	} else {
		assert(house_map[next.x][next.y] == '[' || house_map[next.x][next.y] == ']')
		if try_move_wide_box_lr(house_map, next, delta) {
			house_map[box.x][box.y] = '.'
			house_map[next.x][next.y] = box_c
			return true
		}
		return false
	}
}

try_move_wide_box_ud :: proc(house_map: [][]u8, box: V2, delta: V2) -> bool {
	if valid_move_wide_box_ud(house_map, box, delta) {
		real_move_wide_box_ud(house_map, box, delta, '.')
		return true
	}
	return false
}

real_move_wide_box_ud :: proc(house_map: [][]u8, box: V2, delta: V2, pre_c: u8) {
	box_c := house_map[box.x][box.y]
	if box_c == '.' {
		house_map[box.x][box.y] = pre_c
		return
	}
	assert(box_c != '#')
	assert(box_c == '[' || box_c == ']')
	side_box := box + Move[3] if box_c == '[' else box + Move[2]
	side_box_c := house_map[side_box.x][side_box.y]
	assert((box_c == ']' && side_box_c == '[') || (box_c == '[' && side_box_c == ']'))
	next := box + delta
	side_next := side_box + delta
	real_move_wide_box_ud(house_map, next, delta, box_c)
	real_move_wide_box_ud(house_map, side_next, delta, side_box_c)
	house_map[box.x][box.y] = pre_c
	house_map[side_box.x][side_box.y] = '.'
}

valid_move_wide_box_ud :: proc(house_map: [][]u8, box: V2, delta: V2) -> bool {
	box_c := house_map[box.x][box.y]
	if box_c == '.' {
		return true
	} else if box_c == '#' {
		return false
	}
	assert(box_c == '[' || box_c == ']')
	side_box := box + Move[3] if box_c == '[' else box + Move[2]
	assert(house_map[side_box.x][side_box.y] == '[' || house_map[side_box.x][side_box.y] == ']')
	next := box + delta
	side_next := side_box + delta
	next_valid := valid_move_wide_box_ud(house_map, next, delta)
	side_next_valid := valid_move_wide_box_ud(house_map, side_next, delta)
	return next_valid && side_next_valid
}
