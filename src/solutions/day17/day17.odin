package day17

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

State :: struct {
	reg_a: int,
	reg_b: int,
	reg_c: int,
	pc:    int,
}

Instruction :: #type proc(state: ^State, operand: int) -> (pc: int, out_val: Maybe(int))

Op_Inst := [8]Instruction {
	0 = adv,
	1 = bxl,
	2 = bst,
	3 = jnz,
	4 = bxc,
	5 = out,
	6 = bdv,
	7 = cdv,
}

pow2 :: proc(num: int) -> int {
	ret := 1
	for i in 0 ..< num {
		ret *= 2
	}
	return ret
}

adv :: proc(state: ^State, operand: int) -> (pc: int, out_val: Maybe(int)) {
	numerator := state.reg_a
	denominator := pow2(get_combo_operand(state, operand))
	state.reg_a = numerator / denominator
	return state.pc + 2, nil
}

bxl :: proc(state: ^State, operand: int) -> (pc: int, out_val: Maybe(int)) {
	state.reg_b = state.reg_b ~ operand
	return state.pc + 2, nil
}

bst :: proc(state: ^State, operand: int) -> (pc: int, out_val: Maybe(int)) {
	state.reg_b = get_combo_operand(state, operand) & 7
	return state.pc + 2, nil
}

jnz :: proc(state: ^State, operand: int) -> (pc: int, out_val: Maybe(int)) {
	if state.reg_a != 0 {
		return operand, nil
	}
	return state.pc + 2, nil
}

bxc :: proc(state: ^State, operand: int) -> (pc: int, out_val: Maybe(int)) {
	state.reg_b = state.reg_b ~ state.reg_c
	return state.pc + 2, nil
}

out :: proc(state: ^State, operand: int) -> (pc: int, out_val: Maybe(int)) {
	ret := get_combo_operand(state, operand) & 7
	return state.pc + 2, ret
}

bdv :: proc(state: ^State, operand: int) -> (pc: int, out_val: Maybe(int)) {
	numerator := state.reg_a
	denominator := pow2(get_combo_operand(state, operand))
	state.reg_b = numerator / denominator
	return state.pc + 2, nil
}

cdv :: proc(state: ^State, operand: int) -> (pc: int, out_val: Maybe(int)) {
	numerator := state.reg_a
	denominator := pow2(get_combo_operand(state, operand))
	state.reg_c = numerator / denominator
	return state.pc + 2, nil
}

get_combo_operand :: proc(state: ^State, operand: int) -> int {
	switch operand {
	case 0 ..= 3:
		return operand
	case 4:
		return state.reg_a
	case 5:
		return state.reg_b
	case 6:
		return state.reg_c
	}
	unreachable()
}

part1 :: proc(input: [][]u8) -> int {
	ans := 0
	prog := make([dynamic]int)
	defer delete(prog)
	outs := make([dynamic]int)
	defer delete(outs)

	reg_a, _ := strconv.parse_int(transmute(string)input[0][12:])
	reg_b, _ := strconv.parse_int(transmute(string)input[1][12:])
	reg_c, _ := strconv.parse_int(transmute(string)input[2][12:])
	state := State {
		reg_a = reg_a,
		reg_b = reg_b,
		reg_c = reg_c,
		pc    = 0,
	}

	for c in input[4] {
		switch c {
		case '0' ..= '9':
			append(&prog, int(c - '0'))
		}
	}

	for state.pc < len(prog) {
		opcode := prog[state.pc]
		operand := prog[state.pc + 1]
		next_pc, out_val := Op_Inst[opcode](&state, operand)
		state.pc = next_pc
		if out_val != nil {
			append(&outs, out_val.(int))
		}
	}

	for c, i in outs {
		if i != len(outs) - 1 {
			fmt.printf("%v,", c)
		} else {
			fmt.printf("%v", c)
		}
	}
	fmt.println()
	return ans
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	prog := make([dynamic]int)
	defer delete(prog)

	for c in input[4] {
		switch c {
		case '0' ..= '9':
			append(&prog, int(c - '0'))
		}
	}

	revp := make([]int, len(prog))
	defer delete(revp)

	#reverse for x, ri in prog {
		revp[len(prog) - ri - 1] = x
	}

	ok := dfs(&ans, 0, revp)
	assert(ok)

	return ans
}

/*
2 4
1 5
7 5
0 3
4 1
1 6
5 5
3 0

2 bst 4 b = a % 8
1 bxl 5 b = b xor 5
7 cdv 5 c = a / (2^b)
0 adv 3 a = a / (2^3)
4 bxc 1 b = b xor c
1 bxl 6 b = b xor 6
5 out 5 out b % 8
3 jnz 0

每次输出后判定a决定是否结束，并且a每次循环减少3位，总共16轮循环后等于0
所以a必须时48bit的值，并且由于b和c的值在每次循环时都通过a获得，我们只需要每次对a的末尾3bit枚举，
从程序数字串的末尾反向，每次查找3bit的值即可
*/

dfs :: proc(ans: ^int, idx: int, revp: []int) -> bool {
	old_ans := ans^
	for i in 0 ..< 8 {
		a, b, c: int
		x := old_ans << 3 + i
		a = x
		// it same with my input
		b = a & 7
		b = b ~ 5
		c = a / pow2(b)
		a = a / 8
		b = b ~ c
		b = b ~ 6
		out_val := b & 7

		pass := false
		if idx == 0 {
			pass = a == 0 && out_val == revp[idx]
		} else {
			pass = a != 0 && out_val == revp[idx]
		}

		if pass {
			// fmt.printfln("idx:%v, b:%v, x:%v", idx, revp[idx], x)
			if idx == len(revp) - 1 {
				ans^ = x
				return true
			} else {
				ans^ = x
				if dfs(ans, idx + 1, revp) {
					return true
				}
				ans^ = old_ans
			}
		}
	}
	return false
}
