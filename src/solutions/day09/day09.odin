package day09

import "core:fmt"
import "core:os"
import "core:strings"

part1 :: proc(input: [][]u8) -> int {
	assert(len(input) == 1)
	ans := 0
	disk := make([dynamic]int, 0, 1024)
	defer delete(disk)
	id := 0
	empty := false
	for c in input[0] {
		id_num := -1 if empty else id
		count := int(c - '0')
		for i in 0 ..< count {
			append(&disk, id_num)
		}
		if !empty {
			id += 1
		}
		empty = !empty
	}

	// print_disk(disk[:])
	left := 0
	right := len(disk) - 1

	for left < right {
		if disk[left] != -1 {
			left += 1
			continue
		}
		for right > left {
			if disk[right] == -1 {
				right -= 1
				continue
			} else {
				break
			}
		}
		if left < right {
			disk[left], disk[right] = disk[right], disk[left]
		}
		left += 1
	}
	// print_disk(disk[:])
	for c, i in disk {
		if c == -1 {
			break
		}
		ans += i * c
	}
	return ans
}

print_disk :: proc(disk: []int) {
	for c in disk {
		if c >= 0 {
			fmt.print(c)
		} else {
			fmt.print(".")
		}
	}
	fmt.println()
}

Frag :: struct {
	id:  int,
	pos: int,
	len: int,
}

part2 :: proc(input: [][]u8) -> int {
	assert(len(input) == 1)
	ans := 0
	files := make([dynamic]Frag, 0, 1024)
	holes := make([dynamic]Frag, 0, 1024)
	defer delete(files)
	defer delete(holes)
	id := 0
	empty := false
	cur_pos := 0
	for c in input[0] {
		id_num := -1 if empty else id
		count := int(c - '0')
		frag := Frag {
			id  = id_num,
			pos = cur_pos,
			len = count,
		}
		if empty {
			append(&holes, frag)
		} else {
			append(&files, frag)
		}
		cur_pos += count
		if !empty {
			id += 1
		}
		empty = !empty
	}

	// print_disk(disk[:])
	#reverse for &f in files {
		for &h in holes {
			if h.pos < f.pos && h.len >= f.len {
				f.pos = h.pos
				h.pos += f.len
				h.len -= f.len
				break
			}
		}
	}
	for f in files {
		ans += f.id * (f.pos + f.pos + f.len - 1) * f.len / 2
		// fmt.println(f)
	}
	return ans
}
