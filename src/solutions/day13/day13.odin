package day13

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:text/regex"


part1 :: proc(input: [][]u8) -> int {
	ans := 0
	regex_btn, btn_err := regex.create("Button [A|B]: X\\+(\\d+), Y\\+(\\d+)", {})
	regex_prize, prize_err := regex.create("Prize: X=(\\d+), Y=(\\d+)", {})
	assert(btn_err == nil)
	assert(prize_err == nil)
	defer regex.destroy(regex_btn)
	defer regex.destroy(regex_prize)


	for i := 0; i < len(input); i += 4 {
		cap_a, ok_a := regex.match(regex_btn, transmute(string)input[i])
		cap_b, ok_b := regex.match(regex_btn, transmute(string)input[i + 1])
		cap_p, ok_p := regex.match(regex_prize, transmute(string)input[i + 2])
		assert(ok_b && ok_a && ok_p)
		ax, _ := strconv.parse_int(cap_a.groups[1])
		ay, _ := strconv.parse_int(cap_a.groups[2])
		bx, _ := strconv.parse_int(cap_b.groups[1])
		by, _ := strconv.parse_int(cap_b.groups[2])
		px, _ := strconv.parse_int(cap_p.groups[1])
		py, _ := strconv.parse_int(cap_p.groups[2])
		coef := matrix[2, 2]int{
			ax, bx, 
			ay, by, 
		}

		b := matrix[2, 1]int{
			px, 
			py, 
		}

		ans += min_tokens(coef, b)
		regex.destroy(cap_a)
		regex.destroy(cap_b)
		regex.destroy(cap_p)
		// break
	}

	return ans
}

min_tokens :: proc(coef: matrix[2, 2]int, b: matrix[2, 1]int) -> int {
	det := linalg.determinant(coef)
	if det == 0 {
		tokens: Maybe(int)
		// 检查共线情况, 先检查按钮B，因为花费更少
		if coef[0, 1] * b[1, 0] == coef[1, 1] * b[0, 0] {
			if div, mod := math.divmod(b[0, 0], coef[0, 1]); div >= 1 && mod == 0 {
				tokens = div * 1
			}
		}
		if coef[0, 0] * b[1, 0] == coef[1, 0] * b[0, 0] {
			if div, mod := math.divmod(b[0, 0], coef[0, 0]); div >= 1 && mod == 0 {
				new_tokens := div * 3
				if tokens == nil || new_tokens < tokens.(int) {
					tokens = new_tokens
				}
			}
		}
		if tokens != nil {
			return tokens.(int)
		} else {
			return 0
		}
	}
	cofactor := matrix[2, 2]int{
		+coef[1, 1], -coef[0, 1], 
		-coef[1, 0], +coef[0, 0], 
	}
	cofactor_b := cofactor * b
	div_a, mod_a := math.divmod(cofactor_b[0, 0], det)
	div_b, mod_b := math.divmod(cofactor_b[1, 0], det)

	// fmt.println("coef", coef)
	// fmt.println("b", b)
	// fmt.println("det", det)
	// fmt.println("cofactor", cofactor)
	// fmt.println("cofactor_b", cofactor_b)
	if div_a >= 0 && mod_a == 0 && div_b >= 0 && mod_b == 0 {
		return div_a * 3 + div_b
	}
	return 0
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	regex_btn, btn_err := regex.create("Button [A|B]: X\\+(\\d+), Y\\+(\\d+)", {})
	regex_prize, prize_err := regex.create("Prize: X=(\\d+), Y=(\\d+)", {})
	assert(btn_err == nil)
	assert(prize_err == nil)
	defer regex.destroy(regex_btn)
	defer regex.destroy(regex_prize)


	for i := 0; i < len(input); i += 4 {
		cap_a, ok_a := regex.match(regex_btn, transmute(string)input[i])
		cap_b, ok_b := regex.match(regex_btn, transmute(string)input[i + 1])
		cap_p, ok_p := regex.match(regex_prize, transmute(string)input[i + 2])
		assert(ok_b && ok_a && ok_p)
		ax, _ := strconv.parse_int(cap_a.groups[1])
		ay, _ := strconv.parse_int(cap_a.groups[2])
		bx, _ := strconv.parse_int(cap_b.groups[1])
		by, _ := strconv.parse_int(cap_b.groups[2])
		px, _ := strconv.parse_int(cap_p.groups[1])
		py, _ := strconv.parse_int(cap_p.groups[2])
		coef := matrix[2, 2]int{
			ax, bx, 
			ay, by, 
		}

		b := matrix[2, 1]int{
			px + 10000000000000, 
			py + 10000000000000, 
		}

		ans += min_tokens(coef, b)
		regex.destroy(cap_a)
		regex.destroy(cap_b)
		regex.destroy(cap_p)
		// break
	}

	return ans
}
