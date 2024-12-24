package day24

import "../utils"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

Gate :: enum {
	Literal,
	And,
	Or,
	Xor,
}

Node :: struct {
	name:   string,
	input1: ^Node,
	input2: ^Node,
	gate:   Gate,
	out:    int,
	cached: bool,
}


part1 :: proc(input: [][]u8) -> int {
	ans := 0

	all_node: map[string]^Node
	z_nodes: [64]^Node
	defer {
		for _, v in all_node {
			free(v)
		}
		delete(all_node)
	}

	parsing_literal := true
	for line in input {
		line_s := transmute(string)line
		if len(line_s) == 0 {
			parsing_literal = false
			continue
		}
		if parsing_literal {
			add_literal_node(line_s, &all_node)
		} else {
			node := add_logic_node(line_s, &all_node)
			if node.name[0] == 'z' {
				zi, ok := strconv.parse_int(node.name[1:])
				assert(ok)
				z_nodes[zi] = node
			}
		}

	}
	for zn, i in z_nodes {
		if zn != nil {
			eval_node(zn)
			ans |= zn.out << uint(i)
		}
	}
	return ans
}

eval_node :: proc(node: ^Node) -> int {
	if node.cached {
		return node.out
	}
	assert(node.gate != .Literal)
	v1 := eval_node(node.input1)
	v2 := eval_node(node.input2)
	out: int
	switch node.gate {
	case .And:
		out = v1 & v2
	case .Or:
		out = v1 | v2
	case .Xor:
		out = v1 ~ v2
	case .Literal:
		unreachable()
	}
	node.out = out
	node.cached = true
	return out
}

get_or_create_node :: proc(all_node: ^map[string]^Node, name: string) -> ^Node {
	if name in all_node {
		return all_node[name]
	} else {
		node := new(Node)
		all_node[name] = node
		return node
	}
}

add_literal_node :: proc(line_s: string, all_node: ^map[string]^Node) {
	name := line_s[:3]
	value, _ := strconv.parse_int(line_s[5:])
	node := get_or_create_node(all_node, name)
	node.name = name
	node.cached = true
	node.out = value
	node.gate = .Literal
}

add_logic_node :: proc(line_s: string, all_node: ^map[string]^Node) -> ^Node {
	ss := strings.split(line_s, " ")
	defer delete(ss)
	name := ss[4]
	node := get_or_create_node(all_node, name)
	node.name = name
	node.cached = false
	node.input1 = get_or_create_node(all_node, ss[0])
	node.input2 = get_or_create_node(all_node, ss[2])
	if ss[1] == "AND" {
		node.gate = .And
	} else if ss[1] == "OR" {
		node.gate = .Or
	} else {
		assert(ss[1] == "XOR")
		node.gate = .Xor
	}
	return node
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	return ans
}
