package main

import "core:fmt"
import "core:os"
import "core:strings"
import "solutions/day00"
import "solutions/day01"

main :: proc() {
	day := os.args[1]
	part := os.args[2]
	ans: int
	filename := fmt.aprintf("inputs/day%v.txt", day)
	defer delete(filename)

	data, ok := os.read_entire_file_from_filename(filename)
	if !ok {
		fmt.printfln("load file %v fail!", filename)
		return
	}
	defer delete(data)

	puzzle_data := data_to_u8_slice(data)
	defer delete(puzzle_data)

	switch day {
	case "00":
		if part == "a" {
			ans = day00.part1(puzzle_data)
		} else {
			ans = day00.part2(puzzle_data)
		}
	case "01":
		if part == "a" {
			ans = day01.part1(puzzle_data)
		} else {
			ans = day01.part2(puzzle_data)
		}
	}
	fmt.printfln("day%v part %v, ans is %v", day, part, ans)
}

data_to_u8_slice :: proc(data: []byte) -> [][]u8 {
	dyn := make([dynamic][]u8)
	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		append(&dyn, transmute([]u8)line)
	}

	return dyn[:]
}
