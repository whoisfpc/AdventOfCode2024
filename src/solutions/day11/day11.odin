package day11

import "core:fmt"
import "core:math"
import "core:os"
import "core:strconv"
import "core:strings"

part1 :: proc(input: [][]u8) -> int {
	// order is not important
	num_map, next_map: map[int]int
	defer {
		delete(num_map)
		delete(next_map)
	}
	ans := 0
	assert(len(input) == 1)
	stons_s := transmute(string)input[0]
	for num_s in strings.split_iterator(&stons_s, " ") {
		n, _ := strconv.parse_int(num_s)
		num_map[n] += 1
	}

	for i in 0 ..< 25 {
		blink_nums(&num_map, &next_map)
		num_map, next_map = next_map, num_map
		clear(&next_map)
		// fmt.println(num_map)
	}
	for _, v in num_map {
		ans += v
	}
	return ans
}

blink_nums :: proc(num_map, next_map: ^map[int]int) {
	for k, v in num_map {
		left, right := transfer_num(k)
		next_map[left] += v
		if right != nil {
			next_map[right.(int)] += v
		}
	}
}

transfer_num :: proc(num: int) -> (left: int, right: Maybe(int)) {
	if num == 0 {
		return 1, nil
	}
	digit_count := math.count_digits_of_base(num, 10)
	if digit_count % 2 == 0 {
		divisor := 1
		for i in 0 ..< digit_count / 2 {
			divisor *= 10
		}
		return num / divisor, num % divisor
	} else {
		return num * 2024, nil
	}
}

part2 :: proc(input: [][]u8) -> int {
	num_map, next_map: map[int]int
	defer {
		delete(num_map)
		delete(next_map)
	}
	ans := 0
	assert(len(input) == 1)
	stons_s := transmute(string)input[0]
	for num_s in strings.split_iterator(&stons_s, " ") {
		n, _ := strconv.parse_int(num_s)
		num_map[n] += 1
	}

	for i in 0 ..< 25 {
		blink_nums(&num_map, &next_map)
		num_map, next_map = next_map, num_map
		clear(&next_map)
		// fmt.println(num_map)
	}
	for _, v in num_map {
		ans += v
	}
	return ans
}
