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

part2_brute_force :: proc(input: [][]u8) -> int {
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

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	corrup_map := utils.make_2d(height, width, bool)
	defer utils.destroy_2d(corrup_map)
	corrupts := make([dynamic]V2, 0, len(input))
	defer delete(corrupts)

	for i in 0 ..< len(input) {
		line := transmute(string)input[i]
		comma := strings.index(line, ",")
		// 方便显示，调换x和y
		y, _ := strconv.parse_int(line[:comma])
		x, _ := strconv.parse_int(line[comma + 1:])
		corrup_map[x][y] = true
		append(&corrupts, V2{x, y})
	}
	// print_map(corrup_map)
	ds_map := utils.make_2d(height, width, Ds_Node)
	defer utils.destroy_2d(ds_map)

	for i in 0 ..< height {
		for j in 0 ..< width {
			pos := V2{i, j}
			ds_make(pos, ds_map)
		}
	}

	for line, i in corrup_map {
		for b, j in line {
			if b {
				continue
			}
			pos := V2{i, j}
			for offset in Move {
				new_pos := pos + offset
				if new_pos.x < 0 || new_pos.x >= height || new_pos.y < 0 || new_pos.y >= width {
					continue
				}
				if corrup_map[new_pos.x][new_pos.y] {
					continue
				}
				ds_merge(pos, new_pos, ds_map)
			}
		}
	}

	#reverse for pos, i in corrupts {
		corrup_map[pos.x][pos.y] = false
		for offset in Move {
			new_pos := pos + offset
			if new_pos.x < 0 || new_pos.x >= height || new_pos.y < 0 || new_pos.y >= width {
				continue
			}
			if corrup_map[new_pos.x][new_pos.y] {
				continue
			}
			ds_merge(pos, new_pos, ds_map)
		}
		start_set := ds_find(V2{0, 0}, ds_map)
		end_set := ds_find(V2{height - 1, width - 1}, ds_map)
		if start_set == end_set {
			fmt.printfln("%v,%v", pos.y, pos.x)
			break
		}
	}
	// print_map(corrup_map)

	return ans
}

Ds_Node :: struct {
	pos:    V2,
	parent: V2,
}

// 并查集
ds_make :: proc(pos: V2, ds_map: [][]Ds_Node) {
	ds_map[pos.x][pos.y] = Ds_Node {
		pos    = pos,
		parent = pos,
	}
}

ds_find :: proc(pos: V2, ds_map: [][]Ds_Node) -> V2 {
	x := &ds_map[pos.x][pos.y]
	for x.parent != x.pos {
		x.parent = ds_map[x.parent.x][x.parent.y].parent
		x = &ds_map[x.parent.x][x.parent.y]
	}
	return x.pos
}

ds_merge :: proc(pos1, pos2: V2, ds_map: [][]Ds_Node) {
	root1 := ds_find(pos1, ds_map)
	root2 := ds_find(pos2, ds_map)
	if root1 != root2 {
		ds_map[root1.x][root1.y].parent = root2
	}
}
