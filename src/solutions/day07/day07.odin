package day07

import "core:fmt"
import "core:math"
import "core:os"
import "core:strconv"
import "core:strings"


part1 :: proc(input: [][]u8) -> int {
	ans := 0
	nums := make([dynamic]int, 0, 32)
	defer {
		delete(nums)
	}


	for line in input {
		clear(&nums)
		line_s := transmute(string)line
		colon_idx := strings.index(line_s, ":")
		target, _ := strconv.parse_int(line_s[:colon_idx])
		remain_s := line_s[colon_idx + 2:]
		for num_s in strings.split_iterator(&remain_s, " ") {
			n, _ := strconv.parse_int(num_s)
			append(&nums, n)
		}
		pass := evaluate(nums[:], 0, 0, target)
		if pass {
			ans += target
		}
		// fmt.printfln("pass %v, target is %v, nums %v", pass, target, nums)
	}
	return ans
}

evaluate :: proc(nums: []int, current, idx, target: int) -> bool {
	if idx == len(nums) {
		return current == target
	}

	pass := evaluate(nums, current + nums[idx], idx + 1, target)
	if !pass && idx != 0 {
		pass = evaluate(nums, current * nums[idx], idx + 1, target)
	}
	return pass
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	nums := make([dynamic]int, 0, 32)
	defer {
		delete(nums)
	}

	for line in input {
		clear(&nums)
		line_s := transmute(string)line
		colon_idx := strings.index(line_s, ":")
		target, _ := strconv.parse_int(line_s[:colon_idx])
		remain_s := line_s[colon_idx + 2:]
		for num_s in strings.split_iterator(&remain_s, " ") {
			n, _ := strconv.parse_int(num_s)
			append(&nums, n)
		}
		pass := evaluate2(nums[:], 0, 0, target)
		if pass {
			ans += target
		}
		// fmt.printfln("pass %v, target is %v, nums %v", pass, target, nums)
	}
	return ans
}

evaluate2 :: proc(nums: []int, current, idx, target: int) -> bool {
	if idx == len(nums) {
		return current == target
	}

	pass := evaluate2(nums, current + nums[idx], idx + 1, target)
	if !pass && idx != 0 {
		pass = evaluate2(nums, current * nums[idx], idx + 1, target)
	}
	if !pass && idx != 0 {
		digits := math.count_digits_of_base(nums[idx], 10)
		next := current
		for i in 0 ..< digits {
			next *= 10
		}
		next += nums[idx]
		pass = evaluate2(nums, next, idx + 1, target)
	}
	return pass
}
