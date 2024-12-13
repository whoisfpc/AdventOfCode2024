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

Corner_Move := [4][2]int{{-1, -1}, {-1, +1}, {+1, -1}, {+1, +1}}

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

check_corner :: proc(id_map: [][]int, pos: V2, corner: int) -> bool {
	height, width := len(id_map), len(id_map[0])
	p2 := pos + Corner_Move[corner]
	if p2.x < 0 || p2.x >= height || p2.y < 0 || p2.y >= width {
		return false
	}
	return id_map[p2.x][p2.y] == id_map[pos.x][pos.y]
}

/*
	总的边长数目和顶点数相等，但是要注意共点问题，例如
	AAB
	ABA
	AAA
	上图的A区块有10条边，其中右上角的两个A(0, 1)和(1, 2)共点
	我们将顶点区分成两种，一种类似A区块左上角和右下角的顶点为“凸点”，左下角A和中间B区块相邻的点为“凹点”
	可以通过统计每个位置上下左右4个方向相邻的情况来统计顶点，例如
	X X X  X X X
	X[A]X  X[A]A
	X A X  X X X
	方括号包含的A为当前判定的位置，上图可以确定有2个“凸点产生”，总共有16种可能的情况，每种都可以确认“凸点”数量
	对于“凹点”计算，由于会产生重复判定，因为我们从上到下逐行扫描id_map，所以我们只计算当前位置上半区域的“凹点”
	? A ?  X X ?  ? X X
	X[A]X  X[A]A  A[A]X
	? ? ?  ? ? ?  ? ? ?
	当满足上述图形时，可以判断左上角和右上角的位置是否和当前点位符号一致，来决定是否有“凹点”产生
	统计“凸点”和“凹点”总和，就等于区块的总顶点数
	注意：这种统计方式处理了一开始的共点情况，因为两个A各自都会产生2个“凸点”
*/
get_vertex_count :: proc(around_info: Direction_Set, id_map: [][]int, pos: V2) -> int {
	count := 0
	id := id_map[pos.x][pos.y]
	switch around_info {
	case {}:
		count = 4
	case {.Down}:
		count = 2
	case {.Up}:
		count = 2
		count += 1 if check_corner(id_map, pos, 0) else 0
		count += 1 if check_corner(id_map, pos, 1) else 0
	case {.Left}:
		count = 2
		count += 1 if check_corner(id_map, pos, 0) else 0
	case {.Right}:
		count = 2
		count += 1 if check_corner(id_map, pos, 1) else 0
	case {.Up, .Left}:
		count = 1
		count += 1 if check_corner(id_map, pos, 1) else 0
	case {.Up, .Right}:
		count = 1
		count += 1 if check_corner(id_map, pos, 0) else 0
	case {.Down, .Left}:
		count = 1
		count += 1 if check_corner(id_map, pos, 0) else 0
	case {.Down, .Right}:
		count = 1
		count += 1 if check_corner(id_map, pos, 1) else 0
	case {.Up, .Down}:
		count = 0
		count += 1 if check_corner(id_map, pos, 0) else 0
		count += 1 if check_corner(id_map, pos, 1) else 0
	case {.Left, .Right}:
		count = 0
		count += 1 if check_corner(id_map, pos, 0) else 0
		count += 1 if check_corner(id_map, pos, 1) else 0
	case {.Up, .Down, .Left}:
		count = 0
		count += 1 if check_corner(id_map, pos, 1) else 0
	case {.Up, .Down, .Right}:
		count = 0
		count += 1 if check_corner(id_map, pos, 0) else 0
	case {.Left, .Right, .Down}:
		count = 0
		count += 1 if check_corner(id_map, pos, 0) else 0
		count += 1 if check_corner(id_map, pos, 1) else 0
	case {.Left, .Right, .Up}:
		count = 0
	case {.Up, .Down, .Left, .Right}:
		count = 0
	case:
		unreachable()
	}
	return count
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
			area_info.vertex_count += get_vertex_count(around, id_map, V2{i, j})
			area_map[id] = area_info
		}
	}

	for k, v in area_map {
		// fmt.println(k, v)
		ans += v.area * v.vertex_count
	}
	return ans
}
