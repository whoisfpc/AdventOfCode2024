package day10

import "core:container/queue"
import "core:fmt"
import "core:os"
import "core:strings"

Direction :: enum {
	Up,
	Down,
	Left,
	Right,
}

Direction_Move := [Direction][2]int {
	.Up    = {-1, 0},
	.Down  = {+1, 0},
	.Left  = {0, -1},
	.Right = {0, +1},
}


part1 :: proc(input: [][]u8) -> int {
	ans := 0
	for line, i in input {
		for c, j in line {
			if c == '0' {
				bfs(input, [2]int{i, j}, true, &ans)
			}
		}
	}
	return ans
}

bfs :: proc(input: [][]u8, start: [2]int, check_passed: bool, ans: ^int) {
	height, width := len(input), len(input[0])
	passed: [][]bool = nil
	if check_passed {
		passed = make([][]bool, height)
		for &line in passed {
			line = make([]bool, width)
		}
	}
	defer {
		if passed != nil {
			for line in passed {
				delete(line)
			}
			delete(passed)
		}
	}

	q: queue.Queue([2]int)
	queue.init(&q)
	defer queue.destroy(&q)

	if passed != nil {
		passed[start.x][start.y] = true
	}
	queue.push(&q, start)
	for queue.len(q) > 0 {
		pos := queue.pop_front(&q)
		if input[pos.x][pos.y] == '9' {
			ans^ += 1
			continue
		}
		for offset in Direction_Move {
			new_pos := pos + offset
			if new_pos.x < 0 || new_pos.x >= height || new_pos.y < 0 || new_pos.y >= width {
				continue
			}
			if input[new_pos.x][new_pos.y] - input[pos.x][pos.y] != 1 {
				continue
			}
			if passed != nil && passed[new_pos.x][new_pos.y] {
				continue
			}
			queue.push(&q, new_pos)
			if passed != nil {
				passed[new_pos.x][new_pos.y] = true
			}
		}
	}
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	for line, i in input {
		for c, j in line {
			if c == '0' {
				bfs(input, [2]int{i, j}, false, &ans)
			}
		}
	}
	return ans
}
