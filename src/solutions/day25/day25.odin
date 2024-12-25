package day25

import "../utils"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"


part1 :: proc(input: [][]u8) -> int {
	ans := 0
	keys: [dynamic][5]int
	locks: [dynamic][5]int
	defer delete(keys)
	defer delete(locks)

	lock_header := []u8{'#', '#', '#', '#', '#'}
	key_header := []u8{'.', '.', '.', '.', '.'}
	for i := 0; i < len(input); i += 8 {
		is_lock := slice.equal(input[i], lock_header)
		if !is_lock {
			assert(slice.equal(input[i], key_header))
		}
		pins: [5]int
		for j in 1 ..= 6 {
			for c, k in input[i + j] {
				if c == '#' {
					if is_lock {
						pins[k] = j
					} else {
						pins[k] = max(pins[k], 6 - j)
					}
				}
			}
		}
		if is_lock {
			append(&locks, pins)
		} else {
			append(&keys, pins)
		}
	}

	for lock in locks {
		for key in keys {
			pass := true
			for i in 0 ..< 5 {
				if lock[i] + key[i] > 5 {
					pass = false
					break
				}
			}
			ans += 1 if pass else 0
		}
	}
	return ans
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	return ans
}
