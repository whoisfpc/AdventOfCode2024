package day16

import "../utils"
import pq "core:container/priority_queue"
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

Direction_Move := [Direction][2]int {
	.Up    = {-1, 0},
	.Down  = {+1, 0},
	.Left  = {0, -1},
	.Right = {0, +1},
}

Node :: struct {
	pos:  V2,
	dir:  Direction,
	cost: int,
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

fix_pq :: proc(q: ^pq.Priority_Queue(Node), v: Node) {
	for &node, i in q.queue {
		if node.pos == v.pos && node.dir == v.dir {
			node.cost = v.cost
			pq.fix(q, i)
			break
		}
	}
}

part1 :: proc(input: [][]u8) -> int {
	ans := 0
	height, width := len(input), len(input[0])
	dist := utils.make_2d(height, width, [Direction]int)
	defer utils.destroy_2d(dist)

	q: pq.Priority_Queue(Node)
	pq.init(&q, less_node, pq.default_swap_proc(Node))
	pq.reserve(&q, height * width)
	defer pq.destroy(&q)

	start, end: V2
	for line, i in input {
		for c, j in line {
			for d in Direction {
				dist[i][j][d] = max(int)
				node := Node {
					pos  = V2{i, j},
					dir  = d,
					cost = max(int),
				}
				if c == 'S' && d == .Right {
					node.cost = 0
				}
				pq.push(&q, node)
			}
			if c == 'S' {
				start = V2{i, j}
			} else if c == 'E' {
				end = V2{i, j}
			}
		}
	}
	dist[start.x][start.y][.Right] = 0

	for pq.len(q) > 0 {
		node := pq.pop(&q)
		// fmt.println("pop", node)
		if node.cost == max(int) {
			break
		}

		neighbor: [3]Node
		neighbor[0] = Node {
			pos  = node.pos,
			dir  = turn_left(node.dir),
			cost = node.cost + 1000,
		}
		neighbor[1] = Node {
			pos  = node.pos,
			dir  = turn_right(node.dir),
			cost = node.cost + 1000,
		}
		neighbor[2] = Node {
			pos  = node.pos + Direction_Move[node.dir],
			dir  = node.dir,
			cost = node.cost + 1,
		}

		for v in neighbor {
			if input[v.pos.x][v.pos.y] == '#' {
				continue
			}
			if v.cost < dist[v.pos.x][v.pos.y][v.dir] {
				dist[v.pos.x][v.pos.y][v.dir] = v.cost
				fix_pq(&q, v)
				// fmt.println("fix", v)
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

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	return ans
}
