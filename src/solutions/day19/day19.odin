package day19

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"


part1 :: proc(input: [][]u8) -> int {
	ans := 0
	patterns := make([dynamic][]u8)
	defer delete(patterns)
	s0 := transmute(string)input[0]

	for p in strings.split_iterator(&s0, ", ") {
		append(&patterns, transmute([]u8)p)
	}

	for i in 2 ..< len(input) {
		num := calc_combines(input[i], patterns[:])
		ans += 1 if num > 0 else 0
	}
	return ans
}

calc_combines :: proc(target: []u8, patterns: [][]u8) -> int {
	dp := make([]int, len(target))
	defer delete(dp)

	for _, i in dp {
		for p in patterns {
			n := len(p)
			prev := i - n + 1
			if prev < 0 {
				continue
			}
			pn := 1
			if prev > 0 {
				pn = dp[prev - 1]
			}
			if pn == 0 {
				continue
			}
			tp := target[prev:][:n]
			if slice.equal(tp, p) {
				dp[i] += pn
			}
		}
	}
	return dp[len(dp) - 1]
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	patterns := make([dynamic][]u8)
	defer delete(patterns)
	s0 := transmute(string)input[0]

	for p in strings.split_iterator(&s0, ", ") {
		append(&patterns, transmute([]u8)p)
	}

	for i in 2 ..< len(input) {
		num := calc_combines(input[i], patterns[:])
		ans += num
	}
	return ans
}
