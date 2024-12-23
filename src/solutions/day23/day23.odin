package day23

import "../utils"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

all_names: [26 * 26]string
adj_map: [26 * 26][26 * 26]bool
con_map: map[int][dynamic]int

name_to_index :: proc(name: string) -> int {
	assert(len(name) == 2)
	index := int(name[0] - 'a') * 26 + int(name[1] - 'a')
	return index
}

index_to_name :: proc(index: int) -> string {
	return all_names[index]
}

index_start_t :: proc(index: int) -> bool {
	name := index_to_name(index)
	return name[0] == 't'
}

prepare :: proc() {
	for i in 'a' ..= 'z' {
		for j in 'a' ..= 'z' {
			name := fmt.aprintf("%v%v", i, j)
			index := name_to_index(name)
			all_names[index] = name
		}
	}
}

fill_adj_map :: proc(input: [][]u8, names: ^map[int]bool) {
	for line in input {
		a := transmute(string)line[:2]
		b := transmute(string)line[3:]
		idx_a := name_to_index(a)
		idx_b := name_to_index(b)
		adj_map[idx_a][idx_b] = true
		adj_map[idx_b][idx_a] = true
		names[idx_a] = true
		names[idx_b] = true
		add_con(idx_a, idx_b)
		add_con(idx_b, idx_a)
	}
}

add_con :: proc(a, b: int) {
	if a in con_map {
		append(&con_map[a], b)
	} else {
		list: [dynamic]int
		append(&list, b)
		con_map[a] = list
	}
}

part1 :: proc(input: [][]u8) -> int {
	ans := 0
	names: map[int]bool
	defer delete(names)
	prepare()
	fill_adj_map(input, &names)

	for idx, con in con_map {
		count := len(con)
		for nj in 0 ..< count {
			for nk in nj + 1 ..< count {
				i := idx
				j := con[nj]
				k := con[nk]
				has_t := false
				has_t |= index_start_t(i)
				has_t |= index_start_t(j)
				has_t |= index_start_t(k)
				if !has_t {
					continue
				}
				if adj_map[i][j] && adj_map[i][k] && adj_map[j][k] {
					ans += 1
				}
			}
		}
	}

	return ans / 3
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	prepare()
	return ans
}
