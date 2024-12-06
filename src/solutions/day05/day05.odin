package day05

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

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
	for _, node in graph.all_nodes {
		free(node)
	}
	delete(graph.all_nodes)
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
	has_entry := false
	for _, v in graph.all_nodes {
		if len(v.befores) == 0 {
			walk_update_depth(v, 0)
			has_entry = true
		}
	}
	assert(has_entry)
}

walk_update_depth :: proc(node: ^Node, depth: int) {
	node.depth = max(node.depth, depth)
	for after in node.afters {
		walk_update_depth(after, node.depth + 1)
	}
}

RulePair :: distinct [2]int

part1 :: proc(input: [][]u8) -> int {
	ans := 0

	all_rules := make([dynamic]RulePair)
	defer delete(all_rules)


	parsing_rule := true
	for row in input {
		if len(row) == 0 {
			parsing_rule = false
			continue
		}
		row_s := transmute(string)row
		if parsing_rule {
			splite_idx := strings.index(row_s, "|")
			a, _ := strconv.parse_int(row_s[:splite_idx])
			b, _ := strconv.parse_int(row_s[splite_idx + 1:])
			append(&all_rules, RulePair{a, b})
		} else {
			num_set := make(map[int]bool)
			nums := make([dynamic]int)
			defer {
				delete(num_set)
				delete(nums)
			}

			for num_s in strings.split_iterator(&row_s, ",") {
				c, _ := strconv.parse_int(num_s)
				append(&nums, c)
				num_set[c] = true
			}

			graph: Graph
			depth_map := make(map[int]int)
			defer {
				destroy_graph(&graph)
				delete(depth_map)
			}
			for rule in all_rules {
				has_a := num_set[rule.x]
				has_b := num_set[rule.y]
				if has_a && has_b {
					insert_pair(&graph, rule.x, rule.y)
				}
			}
			build_depth(&graph)
			for _, v in graph.all_nodes {
				depth_map[v.value] = v.depth
			}
			// fmt.println(depth_map)

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
	ans := 0

	all_rules := make([dynamic]RulePair)
	defer delete(all_rules)


	parsing_rule := true
	for row in input {
		if len(row) == 0 {
			parsing_rule = false
			continue
		}
		row_s := transmute(string)row
		if parsing_rule {
			splite_idx := strings.index(row_s, "|")
			a, _ := strconv.parse_int(row_s[:splite_idx])
			b, _ := strconv.parse_int(row_s[splite_idx + 1:])
			append(&all_rules, RulePair{a, b})
		} else {
			num_set := make(map[int]bool)
			nums := make([dynamic][2]int)
			defer {
				delete(num_set)
				delete(nums)
			}

			for num_s in strings.split_iterator(&row_s, ",") {
				c, _ := strconv.parse_int(num_s)
				append(&nums, [2]int{c, 0})
				num_set[c] = true
			}

			graph: Graph
			depth_map := make(map[int]int)
			defer {
				destroy_graph(&graph)
				delete(depth_map)
			}
			for rule in all_rules {
				has_a := num_set[rule.x]
				has_b := num_set[rule.y]
				if has_a && has_b {
					insert_pair(&graph, rule.x, rule.y)
				}
			}
			build_depth(&graph)
			for _, v in graph.all_nodes {
				depth_map[v.value] = v.depth
			}
			for &pair in nums {
				n := pair.x
				pair.y = depth_map[n]
			}
			// fmt.println(depth_map)

			current_depth := 0
			order_right := true
			for pair in nums {
				n := pair.x
				if current_depth > depth_map[n] {
					order_right = false
					break
				}
				current_depth = depth_map[n]
			}
			if !order_right {
				slice.stable_sort_by_cmp(nums[:], proc(i, j: [2]int) -> slice.Ordering {
					if i.y < j.y {
						return .Less
					} else if i.y > j.y {
						return .Greater
					}
					return .Equal
				})
				ans += nums[len(nums) / 2].x
			}
			// fmt.println(order_right, nums[:])
		}
	}
	return ans
}
