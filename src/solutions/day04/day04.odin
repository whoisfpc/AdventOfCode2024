package day04

import "core:fmt"
import "core:os"
import "core:strings"


part1 :: proc(input: [][]u8) -> int {
	ans := 0
	height := len(input)
	width := len(input[0])
	for i in 0 ..< height {
		for j in 0 ..< width {
			if input[i][j] != 'X' {
				continue
			}
			if j + 3 < width && input[i][j + 1] == 'M' && input[i][j + 2] == 'A' && input[i][j + 3] == 'S' {
				ans += 1
			}
			if j >= 3 && input[i][j - 1] == 'M' && input[i][j - 2] == 'A' && input[i][j - 3] == 'S' {
				ans += 1
			}
			if i + 3 < height && input[i + 1][j] == 'M' && input[i + 2][j] == 'A' && input[i + 3][j] == 'S' {
				ans += 1
			}
			if i >= 3 && input[i - 1][j] == 'M' && input[i - 2][j] == 'A' && input[i - 3][j] == 'S' {
				ans += 1
			}
			if i >= 3 && j >= 3 {
				if input[i - 1][j - 1] == 'M' && input[i - 2][j - 2] == 'A' && input[i - 3][j - 3] == 'S' {
					ans += 1
				}
			}
			if i + 3 < height && j + 3 < width {
				if input[i + 1][j + 1] == 'M' && input[i + 2][j + 2] == 'A' && input[i + 3][j + 3] == 'S' {
					ans += 1
				}
			}
			if i >= 3 && j + 3 < width {
				if input[i - 1][j + 1] == 'M' && input[i - 2][j + 2] == 'A' && input[i - 3][j + 3] == 'S' {
					ans += 1
				}
			}
			if i + 3 < height && j >= 3 {
				if input[i + 1][j - 1] == 'M' && input[i + 2][j - 2] == 'A' && input[i + 3][j - 3] == 'S' {
					ans += 1
				}
			}
		}
	}
	return ans
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	height := len(input)
	width := len(input[0])
	for i in 0 ..< height {
		for j in 0 ..< width {
			if input[i][j] != 'A' {
				continue
			}
			if i < 1 || i + 1 >= height || j < 1 || j + 1 >= width {
				continue
			}

			a := input[i - 1][j - 1]
			b := input[i - 1][j + 1]
			c := input[i + 1][j - 1]
			d := input[i + 1][j + 1]

			if a == 'M' && b == 'S' && c == 'M' && d == 'S' {
				ans += 1
			}
			if a == 'M' && b == 'M' && c == 'S' && d == 'S' {
				ans += 1
			}
			if a == 'S' && b == 'M' && c == 'S' && d == 'M' {
				ans += 1
			}
			if a == 'S' && b == 'S' && c == 'M' && d == 'M' {
				ans += 1
			}
		}
	}
	return ans
}
