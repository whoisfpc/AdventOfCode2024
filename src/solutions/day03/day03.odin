package day03

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

calc_mul :: proc(s: string, ans: ^int) -> (next_idx, mul_idx: int) {
	s := s
	total_len := len(s)
	total_idx := 0
	idx := -1
	idx = strings.index(s, "mul(")
	mul_idx = idx
	if idx == -1 {
		return total_len, -1
	}
	total_idx += idx + 4
	s = s[idx + 4:]
	idx = strings.index(s, ",")
	if idx == -1 {
		return total_len, -1
	}
	num1, ok1 := strconv.parse_int(s[:idx])
	if !ok1 {
		return total_idx, -1
	}
	total_idx += idx + 1
	s = s[idx + 1:]
	idx = strings.index(s, ")")
	if idx == -1 {
		return total_len, -1
	}
	num2, ok2 := strconv.parse_int(s[:idx])
	if !ok2 {
		return total_idx, -1
	}
	total_idx += idx + 1

	ans^ += num1 * num2
	return total_idx, mul_idx
}

part1 :: proc(input: [][]u8) -> int {
	ans := 0
	for r in input {
		row := transmute(string)r
		for len(row) > 0 {
			next_idx, _ := calc_mul(row, &ans)
			row = row[next_idx:]
		}
	}
	return ans
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	enable := true
	for r in input {
		row := transmute(string)r
		for len(row) > 0 {
			result := 0
			next_idx, mul_idx := calc_mul(row, &result)
			max_idx := max(next_idx, mul_idx)
			disable_idx := strings.last_index(row[:max_idx], "don't()")
			enable_idx := strings.last_index(row[:next_idx], "do()")
			if disable_idx > enable_idx {
				enable = false
			} else if disable_idx < enable_idx {
				enable = true
			}
			if enable {
				ans += result
			}
			row = row[next_idx:]
		}
	}
	return ans
}
