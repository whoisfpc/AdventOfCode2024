package day05

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

//TODO： not a tree, is a graph
Graph :: struct {
	all_nodes: map[int]^Node,
}

Node :: struct {
	value:   int,
	depth:   int,
	befores: [dynamic]^Node,
	afters:  [dynamic]^Node,
}

destroy_graph :: proc(graph: ^Graph) {
	// todo
}

find_or_create :: proc(graph: ^Graph, value: int) -> ^Node {
	node, ok := graph.all_nodes[value]
	if !ok {
		node = new(Node)
		node.value = value
		graph.all_nodes[value] = node
	}

	assert(node != nil)
	return node
}

insert_pair :: proc(graph: ^Graph, before, after: int) {
	before_node := find_or_create(graph, before)
	after_node := find_or_create(graph, after)
	append(&before_node.afters, after_node)
	append(&after_node.befores, before_node)
}

build_depth :: proc(graph: ^Graph) {
	for _, v in graph.all_nodes {
		if len(v.befores) == 0 {
			walk_update_depth(v, 0)
		}
	}
	// _, has_key := depth_map[current.value]
	// assert(has_key == false)
	// depth_map[current.value] = depth
	// for child in current.children {
	// 	build_depth(child, depth + 1, depth_map)
	// }
}

walk_update_depth :: proc(node: ^Node, depth: int) {
	node.depth = max(node.depth, depth)
	for after in node.afters {
		walk_update_depth(after, node.depth + 1)
	}
}

// TODO: safe rules, and build graph every time
part1 :: proc(input: [][]u8) -> int {
	ans := 0
	graph: Graph
	defer destroy_graph(&graph)
	depth_map := make(map[int]int)
	defer delete(depth_map)

	parsing_rule := true
	for row in input {
		if len(row) == 0 {
			parsing_rule = false
			build_depth(&graph)
			for k, v in graph.all_nodes {
				depth_map[v.value] = v.depth
			}
			fmt.println(depth_map)
			continue
		}
		row_s := transmute(string)row
		if parsing_rule {
			splite_idx := strings.index(row_s, "|")
			a, _ := strconv.parse_int(row_s[:splite_idx])
			b, _ := strconv.parse_int(row_s[splite_idx + 1:])
			insert_pair(&graph, a, b)
		} else {
			nums := make([dynamic]int)
			defer delete(nums)

			for num_s in strings.split_iterator(&row_s, ",") {
				c, _ := strconv.parse_int(num_s)
				append(&nums, c)
			}

			current_depth := 0
			order_right := true
			for n in nums {
				if current_depth > depth_map[n] {
					order_right = false
					break
				}
				current_depth = depth_map[n]
			}
			if order_right {
				ans += nums[len(nums) / 2]
			}
			// fmt.println(order_right, nums[:])
		}
	}
	return ans
}

part2 :: proc(input: [][]u8) -> int {
	return 0
}
