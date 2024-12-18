package day18

import "../utils"
import pq "core:container/priority_queue"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

height :: 71
width :: 71

V2 :: [2]int

Move := [4][2]int {
	0 = {-1, 0},
	1 = {+1, 0},
	2 = {0, -1},
	3 = {0, +1},
}

Node :: struct {
	pos:       V2,
	cost:      int,
	index_map: [][]int `fmt:"-"`,
}

less_node :: proc(a, b: Node) -> bool {
	return a.cost < b.cost
}

get_node_idx :: proc(v: Node) -> int {
	return v.index_map[v.pos.x][v.pos.y]
}

push_pq :: proc(q: ^pq.Priority_Queue(Node), v: Node) {
	v.index_map[v.pos.x][v.pos.y] = pq.len(q^)
	old_idx := get_node_idx(v)
	pq.push(q, v)
	new_idx := get_node_idx(v)
}

pop_pq :: proc(q: ^pq.Priority_Queue(Node)) -> Node {
	v := pq.pop(q)
	v.index_map[v.pos.x][v.pos.y] = -1
	return v
}

fix_pq :: proc(q: ^pq.Priority_Queue(Node), v: Node) {
	idx := get_node_idx(v)
	if idx == -1 {
		push_pq(q, v)
	} else {
		q.queue[idx].cost = v.cost
		pq.fix(q, idx)
	}
}

node_swap_proc :: proc(q: []Node, i, j: int) {
	q[i], q[j] = q[j], q[i]
	q[i].index_map[q[i].pos.x][q[i].pos.y] = i
	q[j].index_map[q[j].pos.x][q[j].pos.y] = j
}


part1 :: proc(input: [][]u8) -> int {
	ans := 0
	corrup_map := utils.make_2d(height, width, bool)
	defer utils.destroy_2d(corrup_map)

	for i in 0 ..< 1024 {
		line := transmute(string)input[i]
		comma := strings.index(line, ",")
		// 方便显示，调换x和y
		y, _ := strconv.parse_int(line[:comma])
		x, _ := strconv.parse_int(line[comma + 1:])
		corrup_map[x][y] = true
	}
	// print_map(corrup_map)
	ans = find_min_dist(corrup_map)
	return ans
}

find_min_dist :: proc(corrup_map: [][]bool) -> int {
	dist := utils.make_2d(height, width, int)
	defer utils.destroy_2d(dist)
	node_pq_map := utils.make_2d(height, width, int)
	defer utils.destroy_2d(node_pq_map)

	for line in dist {
		slice.fill(line, max(int))
	}
	for line in node_pq_map {
		slice.fill(line, -1)
	}

	q: pq.Priority_Queue(Node)
	pq.init(&q, less_node, node_swap_proc)
	pq.reserve(&q, height * width)
	defer pq.destroy(&q)

	start := V2{0, 0}
	end := V2{height - 1, width - 1}

	dist[start.x][start.y] = 0
	start_node := Node {
		pos       = start,
		cost      = 0,
		index_map = node_pq_map,
	}
	push_pq(&q, start_node)

	for pq.len(q) > 0 {
		node := pop_pq(&q)
		for offset in Move {
			new_pos := node.pos + offset
			if new_pos.x < 0 || new_pos.x >= height || new_pos.y < 0 || new_pos.y >= width {
				continue
			}
			if corrup_map[new_pos.x][new_pos.y] {
				continue
			}
			v := Node {
				pos       = new_pos,
				cost      = node.cost + 1,
				index_map = node_pq_map,
			}
			if v.cost < dist[v.pos.x][v.pos.y] {
				dist[v.pos.x][v.pos.y] = v.cost
				fix_pq(&q, v)
			}
		}
	}

	return dist[end.x][end.y]
}

print_map :: proc(corrup_map: [][]bool) {
	for line in corrup_map {
		for b in line {
			if b {
				fmt.print("#")
			} else {
				fmt.print(".")
			}
		}
		fmt.println()
	}
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	corrup_map := utils.make_2d(height, width, bool)
	defer utils.destroy_2d(corrup_map)

	for i in 0 ..< len(input) {
		line := transmute(string)input[i]
		comma := strings.index(line, ",")
		// 方便显示，调换x和y
		y, _ := strconv.parse_int(line[:comma])
		x, _ := strconv.parse_int(line[comma + 1:])
		corrup_map[x][y] = true
		dist := find_min_dist(corrup_map)
		if dist == max(int) {
			fmt.printfln("%v,%v", y, x)
			break
		}
	}
	// print_map(corrup_map)
	return ans
}
