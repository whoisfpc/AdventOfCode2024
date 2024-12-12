package day12

import "core:container/queue"
import "core:fmt"
import "core:os"
import "core:strings"

V2 :: [2]int

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

Area_Info :: struct {
	alpha:        rune,
	area:         int,
	edge_count:   int,
	vertex_count: int,
}

fill_id_map :: proc(id_map: [][]int, input: [][]u8) {
	height, width := len(input), len(input[0])

	q: queue.Queue([2]int)
	defer queue.destroy(&q)
	queue.init(&q)
	id := 0
	for line, i in id_map {
		for _, j in line {
			if id_map[i][j] != 0 {
				continue
			}
			id += 1
			c := input[i][j]
			queue.clear(&q)
			queue.push(&q, V2{i, j})
			id_map[i][j] = id
			for queue.len(q) > 0 {
				pos := queue.pop_front(&q)

				for offset in Direction_Move {
					new_pos := pos + offset
					if new_pos.x < 0 || new_pos.x >= height || new_pos.y < 0 || new_pos.y >= width {
						continue
					}
					if input[new_pos.x][new_pos.y] != c {
						continue
					}
					if id_map[new_pos.x][new_pos.y] != 0 {
						continue
					}
					queue.push(&q, new_pos)
					id_map[new_pos.x][new_pos.y] = id
				}
			}
		}
	}
}

get_around_info :: proc(id_map: [][]int, pos: V2) -> (around_info: Direction_Set) {
	height, width := len(id_map), len(id_map[0])
	c := id_map[pos.x][pos.y]
	for offset, dir in Direction_Move {
		p2 := pos + offset
		if p2.x < 0 || p2.x >= height || p2.y < 0 || p2.y >= width {
			// pass
		} else if id_map[p2.x][p2.y] == c {
			around_info += {dir}
		}
	}
	return around_info
}

get_edge_count :: proc(around_info: Direction_Set) -> int {
	return 4 - card(around_info)
}

get_vertex_count :: proc(around_info: Direction_Set, id_map: [][]int, pos: V2) -> int {
	switch around_info {
	case {}:
		return 4
	case {.Up}, {.Down}, {.Left}, {.Right}:
		return 2
	case {.Up, .Left}, {.Up, .Right}, {.Down, .Left}, {.Down, .Right}:
		return 1
	case {.Up, .Down}, {.Left, .Right}:
		return 0
	case {.Up, .Down, .Left}, {.Up, .Down, .Right}, {.Left, .Right, .Up}, {.Left, .Right, .Down}:
		return 0
	case {.Up, .Down, .Left, .Right}:
		return 0
	}
	unreachable()
}

part1 :: proc(input: [][]u8) -> int {
	ans := 0
	height, width := len(input), len(input[0])
	id_map := make_2d(height, width, int)
	defer destroy_2d(id_map)

	area_map := make(map[int]Area_Info)
	defer delete(area_map)

	fill_id_map(id_map, input)
	// for line in id_map {
	// 	for c in line {
	// 		fmt.print(c, ",")
	// 	}
	// 	fmt.println()
	// }
	for line, i in input {
		for c, j in line {
			around := get_around_info(id_map, V2{i, j})
			id := id_map[i][j]
			assert(id != 0)
			area_info := area_map[id]
			area_info.area += 1
			area_info.alpha = rune(c)
			area_info.edge_count += get_edge_count(around)
			area_map[id] = area_info
		}
	}

	for k, v in area_map {
		// fmt.println(k, v)
		ans += v.area * v.edge_count
	}
	return ans
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	height, width := len(input), len(input[0])
	id_map := make_2d(height, width, int)
	defer destroy_2d(id_map)

	area_map := make(map[int]Area_Info)
	defer delete(area_map)

	fill_id_map(id_map, input)
	// for line in id_map {
	// 	for c in line {
	// 		fmt.print(c, ",")
	// 	}
	// 	fmt.println()
	// }
	for line, i in input {
		for c, j in line {
			around := get_around_info(id_map, V2{i, j})
			id := id_map[i][j]
			assert(id != 0)
			area_info := area_map[id]
			area_info.area += 1
			area_info.alpha = rune(c)
			area_info.vertex_count += get_vertex_count(around, id_map, V2{i, j}
			area_map[id] = area_info
		}
	}

	for k, v in area_map {
		fmt.println(k, v)
		ans += v.area * v.vertex_count
	}
	return ans
}
