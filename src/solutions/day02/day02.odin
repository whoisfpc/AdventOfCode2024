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
	ans := 0

	for row, row_i in input {
		row_s := transmute(string)row
		num_count := strings.count(row_s, " ") + 1
		for skip_idx in -1 ..< num_count {
			row_s = transmute(string)row
			grad := Gradient.None
			pre_num: int
			safe := true
			idx := -1
			first_num := true

			for n in strings.split_iterator(&row_s, " ") {
				idx += 1
				if idx == skip_idx {
					continue
				}
				num, _ := strconv.parse_int(n)
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

			if safe {
				ans += 1
				break
			}
		}
		// fmt.println(row_i, ans)
	}

	return ans
}
