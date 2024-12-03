package day02

import "core:fmt"
import "core:os"
import "core:sort"
import "core:strconv"
import "core:strings"


Gradient :: enum {
	None,
	Ascend,
	Descend,
}

part1 :: proc(input: [][]u8) -> int {
	ans := 0

	for row in input {
		row_s := transmute(string)row
		grad := Gradient.None
		pre_num: int
		safe := true
		idx := -1
		for n in strings.split_iterator(&row_s, " ") {
			idx += 1
			num, _ := strconv.parse_int(n)
			if idx == 0 {
				pre_num = num
				continue
			}
			diff := num - pre_num
			pre_num = num
			if abs(diff) <= 3 && abs(diff) >= 1 {
				if grad == .None {
					grad = .Ascend if diff > 0 else .Descend
				} else if grad == .Ascend {
					if diff < 0 {
						safe = false
						break
					}
				} else if diff > 0 { 	// .Descend
					safe = false
					break
				}
			} else {
				safe = false
				break
			}
		}

		if safe {
			ans += 1
		}
	}

	return ans
}

part2 :: proc(input: [][]u8) -> int {

	check_level :: proc(a, b: int, grad: Gradient) -> bool {
		diff := b - a
		if diff < 0 && grad == .Ascend {
			return false
		}
		if diff > 0 && grad == .Descend {
			return false
		}
		if abs(diff) < 1 || abs(diff) > 3 {
			return false
		}
		return true
	}

	find_invalid_idx :: proc(levels: []int) -> int {
		if len(levels) < 2 {
			return -1
		}
		grad: Gradient = .Ascend if levels[0] < levels[1] else .Descend
		for i in 1 ..< len(levels) {
			a := levels[i - 1]
			b := levels[i]
			if !check_level(a, b, grad) {
				return i
			}
		}
		return -1
	}

	check_level_skip_idx :: proc(levels: []int, skip_idx: int) -> bool {
		grad := Gradient.None
		pre_num: int
		safe := true
		first_num := true

		for num, idx in levels {
			if idx == skip_idx {
				continue
			}
			if first_num {
				pre_num = num
				first_num = false
				continue
			}
			diff := num - pre_num
			pre_num = num
			if abs(diff) <= 3 && abs(diff) >= 1 {
				if grad == .None {
					grad = .Ascend if diff > 0 else .Descend
				} else if grad == .Ascend {
					if diff < 0 {
						safe = false
						break
					}
				} else if diff > 0 { 	// .Descend
					safe = false
					break
				}
			} else {
				safe = false
				break
			}
		}
		return safe
	}

	row_levels := make([dynamic]int)
	defer delete(row_levels)
	ans := 0

	for row, row_i in input {
		row_s := transmute(string)row
		clear(&row_levels)
		for n in strings.split_iterator(&row_s, " ") {
			num, _ := strconv.parse_int(n)
			append(&row_levels, num)
		}

		first_invalid_idx := find_invalid_idx(row_levels[:])
		if first_invalid_idx == -1 {
			ans += 1
			continue
		}
		skip_start := max(0, first_invalid_idx - 2)
		skip_last := first_invalid_idx

		for skip_idx in skip_start ..= skip_last {
			if check_level_skip_idx(row_levels[:], skip_idx) {
				ans += 1
				break
			}
		}
	}

	return ans
}
