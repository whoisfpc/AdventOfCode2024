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

add_literal_node :: proc(line_s: string, all_node: ^map[string]^Node) -> ^Node {
	name := line_s[:3]
	value, _ := strconv.parse_int(line_s[5:])
	node := get_or_create_node(all_node, name)
	node.name = name
	node.cached = true
	node.out = value
	node.gate = .Literal
	return node
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

	all_node: map[string]^Node
	x_inputs: [64]int
	y_inputs: [64]int
	z_nodes: [64]^Node
	defer {
		for _, v in all_node {
			free(v)
		}
		delete(all_node)
	}

	flip_x := 8
	parsing_literal := true
	for line in input {
		line_s := transmute(string)line
		if len(line_s) == 0 {
			parsing_literal = false
			continue
		}
		if parsing_literal {
			node := add_literal_node(line_s, &all_node)
			if node.name[0] == 'x' {
				xi, ok := strconv.parse_int(node.name[1:])
				assert(ok)
				if xi == flip_x {
					node.out ~= 1
				}
				x_inputs[xi] = node.out
			} else {
				assert(node.name[0] == 'y')
				yi, ok := strconv.parse_int(node.name[1:])
				assert(ok)
				y_inputs[yi] = node.out
			}
		} else {
			node := add_logic_node(line_s, &all_node)
			if node.name[0] == 'z' {
				zi, ok := strconv.parse_int(node.name[1:])
				assert(ok)
				z_nodes[zi] = node
			}
		}

	}

	xdec, ydec: int
	for i in 0 ..< 64 {
		xdec |= x_inputs[i] << uint(i)
		ydec |= y_inputs[i] << uint(i)
	}
	zout := xdec + ydec
	fmt.println(xdec, ydec, zout)

	for zn, i in z_nodes {
		if zn != nil {
			eval_node(zn)
			ans |= zn.out << uint(i)
			zout_bit := (zout >> uint(i)) & 1
			if zn.out != zout_bit {
				fmt.printfln("wrong bit: %v", i)
			}
		}
	}

	wrong_wires := []string{"ffj", "z08", "dwp", "kfm", "z31", "jdr", "z22", "gjh"}
	slice.sort(wrong_wires)
	for s, i in wrong_wires {
		if i == 0 {
			fmt.print(s)
		} else {
			fmt.printf(",%v", s)
		}
	}
	fmt.println()
	return ans
}

generate_graphviz :: proc(input: [][]u8) {
	parsing_literal := true
	for line in input {
		line_s := transmute(string)line
		if len(line_s) == 0 {
			parsing_literal = false
			continue
		}
		if parsing_literal {
			continue
		}
		print_graphviz(line_s)
	}
}

print_graphviz :: proc(line_s: string) {
	ss := strings.split(line_s, " ")
	defer delete(ss)
	gate_name := fmt.aprintf("%v%v", ss[1], ss[4])
	defer delete(gate_name)
	fmt.printfln("%v -> %v;", ss[0], gate_name)
	fmt.printfln("%v -> %v;", ss[2], gate_name)
	fmt.printfln("%v -> %v;", gate_name, ss[4])
	fmt.printfln("%v [shape=diamond label=\"%v\"];", gate_name, ss[1])
}
