package day22

import "../utils"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"


part1 :: proc(input: [][]u8) -> int {
	ans := 0
	for line in input {
		line_s := transmute(string)line
		sec, _ := strconv.parse_int(line_s)
		for i in 1 ..= 2000 {
			sec = get_next_secret(sec)
		}
		ans += sec
	}
	return ans
}

get_next_secret :: proc(secret: int) -> int {
	secret := secret
	secret = ((secret * 64) ~ secret) % 16777216
	secret = ((secret / 32) ~ secret) % 16777216
	secret = ((secret * 2048) ~ secret) % 16777216
	return secret
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	return ans
}
