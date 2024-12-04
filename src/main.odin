package main

import "core:fmt"
import "core:os"
import "core:strings"
import "solutions/day00"
import "solutions/day01"
import "solutions/day02"
import "solutions/day03"
import "solutions/day04"

Solver :: #type proc(input: [][]u8) -> int

main :: proc() {

	solvers_part1 := make(map[string]Solver)
	solvers_part2 := make(map[string]Solver)
	defer {
		delete(solvers_part1)
		delete(solvers_part2)
	}
	solvers_part1["00"] = day00.part1
	solvers_part1["01"] = day01.part1
	solvers_part1["02"] = day02.part1
	solvers_part1["03"] = day03.part1
	solvers_part1["04"] = day04.part1

	solvers_part2["00"] = day00.part2
	solvers_part2["01"] = day01.part2
	solvers_part2["02"] = day02.part2
	solvers_part2["03"] = day03.part2
	solvers_part2["04"] = day04.part2

	day := os.args[1]
	part := os.args[2]
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

	solver_proc: Solver = nil
	if part == "a" {
		solver_proc = solvers_part1[day]
	} else {
		solver_proc = solvers_part2[day]
	}
	if solver_proc != nil {
		ans := solver_proc(puzzle_data)
		fmt.printfln("day%v part %v, ans is %v", day, part, ans)
	} else {
		fmt.printfln("can not found solover for day%v part %v", day, part)
	}
}

data_to_u8_slice :: proc(data: []byte) -> [][]u8 {
	dyn := make([dynamic][]u8)
	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		append(&dyn, transmute([]u8)line)
	}

	return dyn[:]
}
