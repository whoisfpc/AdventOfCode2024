package day22

import "../utils"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

V4 :: [4]int

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

	all_secrets: [dynamic]int
	defer delete(all_secrets)
	all_seqs: [dynamic]map[V4]int
	flat_seqs: map[V4]bool
	defer {
		defer delete(flat_seqs)
		for seqs in all_seqs {
			delete(seqs)
		}
		delete(all_seqs)
	}

	for line in input {
		clear(&all_secrets)
		line_s := transmute(string)line
		sec, _ := strconv.parse_int(line_s)
		append(&all_secrets, sec % 10)
		for i in 1 ..= 2000 {
			sec = get_next_secret(sec)
			append(&all_secrets, sec % 10)
		}

		seqs: map[V4]int
		for num, i in all_secrets {
			if i < 4 {
				continue
			}
			seq: V4
			seq[0] = all_secrets[i - 3] - all_secrets[i - 4]
			seq[1] = all_secrets[i - 2] - all_secrets[i - 3]
			seq[2] = all_secrets[i - 1] - all_secrets[i - 2]
			seq[3] = all_secrets[i] - all_secrets[i - 1]
			if !(seq in seqs) {
				seqs[seq] = num
			}
			flat_seqs[seq] = true
		}
		append(&all_seqs, seqs)
	}

	banans := 0
	for seq in flat_seqs {
		banans = 0
		for seqs in all_seqs {
			banans += seqs[seq]
		}
		if banans > ans {
			ans = banans
		}
	}
	return ans
}
