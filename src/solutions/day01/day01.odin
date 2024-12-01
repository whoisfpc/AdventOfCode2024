package day01

import "core:fmt"
import "core:os"
import "core:sort"
import "core:strings"


part1 :: proc(input: [][]u8) -> int {
	nums_count := len(input)
	left_nums := make([dynamic]int, 0, nums_count)
	right_nums := make([dynamic]int, 0, nums_count)
	defer {
		delete(left_nums)
		delete(right_nums)
	}
	for row in input {
		num := 0
		is_left := true
		for c in row {
			if c == ' ' && is_left {
				is_left = false
				append(&left_nums, num)
				num = 0
			} else if c != ' ' {
				num = num * 10 + int(c - '0')
			}
		}
		append(&right_nums, num)
	}

	sort.quick_sort(left_nums[:])
	sort.quick_sort(right_nums[:])

	ans := 0
	for i in 0 ..< nums_count {
		ans += abs(left_nums[i] - right_nums[i])
	}
	return ans
}

part2 :: proc(input: [][]u8) -> int {
	nums_count := len(input)
	left_nums := make([dynamic]int, 0, nums_count)
	right_map := make(map[int]int)
	defer {
		delete(left_nums)
		delete(right_map)
	}
	for row in input {
		num := 0
		is_left := true
		for c in row {
			if c == ' ' && is_left {
				is_left = false
				append(&left_nums, num)
				num = 0
			} else if c != ' ' {
				num = num * 10 + int(c - '0')
			}
		}
		times, ok := right_map[num]
		if ok {
			right_map[num] = times + 1
		} else {
			right_map[num] = 1
		}
	}

	ans := 0
	for n in left_nums {
		if n in right_map {
			ans += right_map[n] * n
		}
	}
	return ans
}
