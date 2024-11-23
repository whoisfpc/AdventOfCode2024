package day00

import "core:fmt"
import "core:os"
import "core:strings"

// Advent of Code 2023 day01, there for test only

part1 :: proc(input: [][]u8) -> int {
	total := 0
	for line in input {
		first, last := 0, 0
		is_first := true
		for c in line {
			switch c {
			case '0' ..= '9':
				d := int(c) - int('0')
				if is_first {
					is_first = false
					first, last = d, d
				} else {
					last = d
				}
			}
		}
		total += first * 10 + last
	}
	return total
}

part2 :: proc(input: [][]u8) -> int {
	return 0
}
