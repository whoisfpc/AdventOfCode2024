package day21

import "../utils"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

Pair :: [2]u8
V2 :: [2]int

Cost_Params :: struct {
	a, b:   u8,
	dirpad: bool,
	depth:  int,
}

Move := [4][2]int {
	0 = {-1, 0},
	1 = {+1, 0},
	2 = {0, -1},
	3 = {0, +1},
}

Move_Char := [4]u8 {
	0 = '^',
	1 = 'v',
	2 = '<',
	3 = '>',
}

numpad_grid := [][]u8{{'7', '8', '9'}, {'5', '5', '6'}, {'1', '2', '3'}, {'X', '0', 'A'}}
dirpad_grid := [][]u8{{'X', '^', 'A'}, {'<', 'v', '>'}}

numpads := map[u8]V2 {
	'7' = V2{0, 0},
	'8' = V2{0, 1},
	'9' = V2{0, 2},
	'4' = V2{1, 0},
	'5' = V2{1, 1},
	'6' = V2{1, 2},
	'1' = V2{2, 0},
	'2' = V2{2, 1},
	'3' = V2{2, 2},
	'0' = V2{3, 1},
	'A' = V2{3, 2},
}

dirpads := map[u8]V2 {
	'^' = V2{0, 1},
	'A' = V2{0, 2},
	'<' = V2{1, 0},
	'v' = V2{1, 1},
	'>' = V2{1, 2},
}

numpad_paths: map[Pair][dynamic][]u8
dirpad_paths: map[Pair][dynamic][]u8
cost_cache: map[Cost_Params]int


prepare :: proc() {
	clear(&cost_cache)
	clear(&numpad_paths)
	clear(&dirpad_paths)
	for key1, a in numpads {
		for key2, b in numpads {
			all_path := prepare_paths(a, b, numpad_grid)
			numpad_paths[Pair{key1, key2}] = all_path
		}
	}
	for key1, a in dirpads {
		for key2, b in dirpads {
			all_path := prepare_paths(a, b, dirpad_grid)
			dirpad_paths[Pair{key1, key2}] = all_path
		}
	}

	// all path are same legnth
	// for k, v in numpad_paths {
	// 	cost := -1
	// 	for p in v {
	// 		if cost == -1 {
	// 			cost = len(p)
	// 		} else {
	// 			assert(cost == len(p))
	// 		}
	// 	}
	// }
	// for k, v in dirpad_paths {
	// 	cost := -1
	// 	for p in v {
	// 		if cost == -1 {
	// 			cost = len(p)
	// 		} else {
	// 			assert(cost == len(p))
	// 		}
	// 	}
	// }
}

prepare_paths :: proc(a, b: V2, grid: [][]u8) -> [dynamic][]u8 {
	all_path := make([dynamic][]u8)
	path := make([dynamic]u8)
	defer delete(path)

	dfs_paths(a, b, grid, &path, &all_path)
	return all_path
}

dfs_paths :: proc(cur, end: V2, grid: [][]u8, path: ^[dynamic]u8, all_path: ^[dynamic][]u8) {
	// fmt.println("dfs", cur, end)
	if grid[cur.x][cur.y] == 'X' {
		return
	}
	if cur == end {
		append(path, 'A')
		new_path := slice.clone(path[:])
		append(all_path, new_path)
		pop(path)
		return
	}
	diff := end - cur
	dist := abs(diff.x) + abs(diff.y)
	for offset, i in Move {
		next := cur + offset
		new_diff := end - next
		new_dist := abs(new_diff.x) + abs(new_diff.y)
		if new_dist >= dist {
			continue
		}
		append(path, Move_Char[i])
		dfs_paths(next, end, grid, path, all_path)
		pop(path)
	}
}

part1 :: proc(input: [][]u8) -> int {
	ans := 0
	prepare()

	for line in input {
		num, _ := strconv.parse_int(transmute(string)line[:len(line) - 1])
		cost := get_code_cost(line, 2)
		fmt.println(cost, num)
		ans += num * cost
	}
	return ans
}

get_code_cost :: proc(code: []u8, depth: int) -> int {
	cost := 0
	for _, i in code {
		a := 'A' if i == 0 else code[i - 1]
		b := code[i]
		cost += get_cost(a, b, false, depth)
	}
	return cost
}

get_all_path :: proc(a, b: u8, dirpad: bool) -> [dynamic][]u8 {
	if dirpad {
		return dirpad_paths[{a, b}]
	} else {
		return numpad_paths[{a, b}]
	}
}

get_cost :: proc(a, b: u8, dirpad: bool, depth: int) -> int {
	cost_params := Cost_Params {
		a      = a,
		b      = b,
		dirpad = dirpad,
		depth  = depth,
	}
	if cost_params in cost_cache {
		return cost_cache[cost_params]
	}

	if depth == 0 {
		assert(dirpad)
		// all path are same legnth
		numpad_cost := len(get_all_path(a, b, dirpad)[0])
		return numpad_cost
	}

	// 除了第一层depth，这里拿出来的都是dirpad的路径
	// 解法就是对numpad的每一次移动，找到套娃多次后的dirpad长度最小的值，并且使用cost_cache缓存避免重复计算
	paths := get_all_path(a, b, dirpad)
	min_cost := max(int)
	for path in paths {
		cost := 0
		for _, i in path {
			a := 'A' if i == 0 else path[i - 1]
			b := path[i]
			cost += get_cost(a, b, true, depth - 1)
		}
		min_cost = min(min_cost, cost)
	}

	cost_cache[cost_params] = min_cost
	return min_cost
}

print_paths :: proc(paths: map[Pair][dynamic][]u8) {
	for k, v in paths {
		fmt.printf("(%v,%v): ", rune(k.x), rune(k.y))
		for p in v {
			fmt.print("[")
			for c in p {
				fmt.printf("%v, ", rune(c))
			}
			fmt.print("],")
		}
		fmt.println()
	}
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	prepare()

	for line in input {
		num, _ := strconv.parse_int(transmute(string)line[:len(line) - 1])
		cost := get_code_cost(line, 25)
		fmt.println(cost, num)
		ans += num * cost
	}
	return ans
}
