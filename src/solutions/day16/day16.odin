package day16

import "../utils"
import pq "core:container/priority_queue"
import "core:container/queue"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

V2 :: [2]int

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

Node :: struct {
	pos:       V2,
	dir:       Direction,
	cost:      int,
	index_map: [][][Direction]int `fmt:"-"`,
}

less_node :: proc(a, b: Node) -> bool {
	return a.cost < b.cost
}

turn_left :: proc(dir: Direction) -> Direction {
	switch dir {
	case .Up:
		return .Left
	case .Down:
		return .Right
	case .Left:
		return .Down
	case .Right:
		return .Up
	}
	unreachable()
}

turn_right :: proc(dir: Direction) -> Direction {
	switch dir {
	case .Up:
		return .Right
	case .Down:
		return .Left
	case .Left:
		return .Up
	case .Right:
		return .Down
	}
	unreachable()
}

get_node_idx :: proc(v: Node) -> int {
	return v.index_map[v.pos.x][v.pos.y][v.dir]
}

push_pq :: proc(q: ^pq.Priority_Queue(Node), v: Node) {
	v.index_map[v.pos.x][v.pos.y][v.dir] = pq.len(q^)
	old_idx := get_node_idx(v)
	pq.push(q, v)
	new_idx := get_node_idx(v)
}

pop_pq :: proc(q: ^pq.Priority_Queue(Node)) -> Node {
	v := pq.pop(q)
	v.index_map[v.pos.x][v.pos.y][v.dir] = -1
	return v
}

fix_pq :: proc(q: ^pq.Priority_Queue(Node), v: Node) {
	idx := get_node_idx(v)
	if idx == -1 {
		push_pq(q, v)
	} else {
		n := q.queue[idx]
		if !(n.pos == v.pos && n.dir == v.dir) {
			fmt.println(idx, n, v)
			assert(false)
		}

		q.queue[idx].cost = v.cost
		pq.fix(q, idx)
	}
}

node_swap_proc :: proc(q: []Node, i, j: int) {
	q[i], q[j] = q[j], q[i]
	q[i].index_map[q[i].pos.x][q[i].pos.y][q[i].dir] = i
	q[j].index_map[q[j].pos.x][q[j].pos.y][q[j].dir] = j
}

part1 :: proc(input: [][]u8) -> int {
	ans := 0
	height, width := len(input), len(input[0])
	dist := utils.make_2d(height, width, [Direction]int)
	defer utils.destroy_2d(dist)
	node_pq_map := utils.make_2d(height, width, [Direction]int)
	defer utils.destroy_2d(node_pq_map)

	for line in node_pq_map {
		for &c in line {
			for &d in c {
				d = -1
			}
		}
	}

	q: pq.Priority_Queue(Node)
	pq.init(&q, less_node, node_swap_proc)
	pq.reserve(&q, height * width)
	defer pq.destroy(&q)

	start, end: V2
	for line, i in input {
		for c, j in line {
			for d in Direction {
				dist[i][j][d] = max(int)
			}
			if c == 'S' {
				start = V2{i, j}
			} else if c == 'E' {
				end = V2{i, j}
			}
		}
	}
	dist[start.x][start.y][.Right] = 0
	start_node := Node {
		pos       = start,
		dir       = .Right,
		cost      = 0,
		index_map = node_pq_map,
	}
	push_pq(&q, start_node)

	for pq.len(q) > 0 {
		node := pop_pq(&q)
		neighbor: [3]Node
		neighbor[0] = Node {
			pos       = node.pos,
			dir       = turn_left(node.dir),
			cost      = node.cost + 1000,
			index_map = node_pq_map,
		}
		neighbor[1] = Node {
			pos       = node.pos,
			dir       = turn_right(node.dir),
			cost      = node.cost + 1000,
			index_map = node_pq_map,
		}
		neighbor[2] = Node {
			pos       = node.pos + Direction_Move[node.dir],
			dir       = node.dir,
			cost      = node.cost + 1,
			index_map = node_pq_map,
		}

		for v in neighbor {
			if input[v.pos.x][v.pos.y] == '#' {
				continue
			}
			if v.cost < dist[v.pos.x][v.pos.y][v.dir] {
				dist[v.pos.x][v.pos.y][v.dir] = v.cost
				fix_pq(&q, v)
			}
		}
	}

	ans = min(
		dist[end.x][end.y][.Up],
		dist[end.x][end.y][.Down],
		dist[end.x][end.y][.Left],
		dist[end.x][end.y][.Right],
	)
	return ans
}

Path :: struct {
	nodes: [dynamic]Node,
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	height, width := len(input), len(input[0])
	dist := utils.make_2d(height, width, [Direction]int)
	defer utils.destroy_2d(dist)
	prev := utils.make_2d(height, width, [Direction]Path)
	defer {
		for line in prev {
			for d in line {
				for p in d {
					delete(p.nodes)
				}
			}
		}
		utils.destroy_2d(prev)
	}

	node_pq_map := utils.make_2d(height, width, [Direction]int)
	defer utils.destroy_2d(node_pq_map)

	for line in node_pq_map {
		for &c in line {
			for &d in c {
				d = -1
			}
		}
	}

	q: pq.Priority_Queue(Node)
	pq.init(&q, less_node, node_swap_proc)
	pq.reserve(&q, height * width)
	defer pq.destroy(&q)

	start, end: V2
	for line, i in input {
		for c, j in line {
			for d in Direction {
				dist[i][j][d] = max(int)
				prev[i][j][d].nodes = make([dynamic]Node)
			}
			if c == 'S' {
				start = V2{i, j}
			} else if c == 'E' {
				end = V2{i, j}
			}
		}
	}
	dist[start.x][start.y][.Right] = 0
	start_node := Node {
		pos       = start,
		dir       = .Right,
		cost      = 0,
		index_map = node_pq_map,
	}
	push_pq(&q, start_node)

	for pq.len(q) > 0 {
		node := pop_pq(&q)
		neighbor: [3]Node
		neighbor[0] = Node {
			pos       = node.pos,
			dir       = turn_left(node.dir),
			cost      = node.cost + 1000,
			index_map = node_pq_map,
		}
		neighbor[1] = Node {
			pos       = node.pos,
			dir       = turn_right(node.dir),
			cost      = node.cost + 1000,
			index_map = node_pq_map,
		}
		neighbor[2] = Node {
			pos       = node.pos + Direction_Move[node.dir],
			dir       = node.dir,
			cost      = node.cost + 1,
			index_map = node_pq_map,
		}

		for v in neighbor {
			if input[v.pos.x][v.pos.y] == '#' {
				continue
			}
			if v.cost < dist[v.pos.x][v.pos.y][v.dir] {
				dist[v.pos.x][v.pos.y][v.dir] = v.cost
				clear(&prev[v.pos.x][v.pos.y][v.dir].nodes)
				append(&prev[v.pos.x][v.pos.y][v.dir].nodes, node)
				fix_pq(&q, v)
			} else if v.cost == dist[v.pos.x][v.pos.y][v.dir] {
				append(&prev[v.pos.x][v.pos.y][v.dir].nodes, node)
			}
		}
	}

	// for line, i in prev {
	// 	for c, j in line {
	// 		if input[i][j] != '#' {
	// 			for d, dir in c {
	// 				fmt.printfln("pos: (%v, %v) dir: %v, nodes: %v", i, j, dir, d.nodes)
	// 			}
	// 		}
	// 	}
	// }

	sit_map := utils.make_2d(height, width, bool)
	defer utils.destroy_2d(sit_map)

	fill_sit_map(sit_map, prev, end, dist)
	// print_sit_map(sit_map, input)
	for line in sit_map {
		for b in line {
			if b {
				ans += 1
			}
		}
	}
	return ans
}

print_sit_map :: proc(sit_map: [][]bool, input: [][]u8) {
	for line, i in input {
		for c, j in line {
			if sit_map[i][j] {
				fmt.print("O")
			} else {
				fmt.print(rune(c))
			}
		}
		fmt.println()
	}
}

fill_sit_map :: proc(sit_map: [][]bool, prev: [][][Direction]Path, end: V2, dist: [][][Direction]int) {

	min_cost := min(
		dist[end.x][end.y][.Up],
		dist[end.x][end.y][.Down],
		dist[end.x][end.y][.Left],
		dist[end.x][end.y][.Right],
	)
	height, width := len(sit_map), len(sit_map[0])

	q: queue.Queue(Node)
	queue.init(&q)
	defer queue.destroy(&q)

	sit_map[end.x][end.y] = true
	for p, dir in prev[end.x][end.y] {
		for n in p.nodes {
			if dist[end.x][end.y][dir] == min_cost {
				queue.push(&q, n)
			}
		}
	}

	for queue.len(q) > 0 {
		node := queue.pop_front(&q)
		cur := node.pos
		sit_map[cur.x][cur.y] = true
		for n in prev[cur.x][cur.y][node.dir].nodes {
			queue.push_back(&q, n)
		}
	}
}
