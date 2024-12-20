package day20

import "../utils"
import "core:container/queue"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

V2 :: [2]int
Move := [?][2]int{{-1, 0}, {+1, 0}, {0, -1}, {0, +1}}


part1 :: proc(input: [][]u8) -> int {
	ans := 0
	height, width := len(input), len(input[0])
	dist := utils.make_2d(height, width, int)
	defer utils.destroy_2d(dist)
	path := make([dynamic]V2)
	defer delete(path)

	start, end: V2
	for line, i in input {
		for c, j in line {
			if c == 'S' {
				start = V2{i, j}
			} else if c == 'E' {
				end = V2{i, j}
			}
		}
	}
	racetrack(input, start, dist, &path)

	old_dist := dist[end.x][end.y]
	for p in path {
		ans += dig_wall(input, p, dist, old_dist, 100, 2, nil)
	}
	return ans
}

dig_wall :: proc(
	input: [][]u8,
	start: V2,
	dist: [][]int,
	old_dist, save_dist, hole_max: int,
	save_map: ^map[int]int,
) -> int {
	height, width := len(input), len(input[0])
	hole_dist := utils.make_2d(height, width, int)
	defer utils.destroy_2d(hole_dist)
	q: queue.Queue(V2)
	defer queue.destroy(&q)

	queue.init(&q)
	queue.push(&q, start)

	ret := 0
	for queue.len(q) > 0 {
		pos := queue.pop_front(&q)
		pre_dist := hole_dist[pos.x][pos.y]
		if input[pos.x][pos.y] != '#' && pos != start {
			// TODO: check hole path
			new_min := dist[start.x][start.y] + pre_dist + (old_dist - dist[pos.x][pos.y])
			if old_dist - new_min > 0 && save_map != nil {
				save_map[old_dist - new_min] += 1
			}
			if old_dist - new_min >= save_dist {
				// fmt.println(start, pos, old_dist - new_min, pre_dist)
				ret += 1
			}
		}
		// if input[pos.x][pos.y] == 'E' && pos != start {
		// 	continue
		// }
		for offset in Move {
			new_pos := pos + offset
			if new_pos.x < 0 || new_pos.x >= height || new_pos.y < 0 || new_pos.y >= width {
				continue
			}
			if new_pos == start {
				continue
			}

			if hole_dist[new_pos.x][new_pos.y] != 0 {
				continue
			}

			if pre_dist >= hole_max {
				assert(pre_dist == hole_max)
				continue
			}
			queue.push(&q, new_pos)
			hole_dist[new_pos.x][new_pos.y] = pre_dist + 1
		}
	}
	return ret
}

racetrack :: proc(input: [][]u8, start: V2, dist: [][]int, path: ^[dynamic]V2) {
	height, width := len(input), len(input[0])
	passed := utils.make_2d(height, width, bool)
	defer utils.destroy_2d(passed)
	q: queue.Queue(V2)
	defer queue.destroy(&q)

	queue.init(&q)
	queue.push(&q, start)
	passed[start.x][start.y] = true

	moved_dist := 0
	for queue.len(q) > 0 {
		pos := queue.pop_front(&q)
		append(path, pos)
		dist[pos.x][pos.y] = moved_dist
		for offset in Move {
			new_pos := pos + offset

			if input[new_pos.x][new_pos.y] == '#' {
				continue
			}
			if passed[new_pos.x][new_pos.y] {
				continue
			}
			queue.push(&q, new_pos)
			passed[new_pos.x][new_pos.y] = true
			moved_dist += 1
		}
		assert(queue.len(q) <= 1)
	}
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	height, width := len(input), len(input[0])
	dist := utils.make_2d(height, width, int)
	defer utils.destroy_2d(dist)
	path := make([dynamic]V2)
	defer delete(path)

	start, end: V2
	for line, i in input {
		for c, j in line {
			if c == 'S' {
				start = V2{i, j}
			} else if c == 'E' {
				end = V2{i, j}
			}
		}
	}
	racetrack(input, start, dist, &path)

	save_map := make(map[int]int)
	defer delete(save_map)
	old_dist := dist[end.x][end.y]
	for p in path {
		ans += dig_wall(input, p, dist, old_dist, 100, 20, &save_map)
	}
	// fmt.println(save_map)
	return ans
}
