package main

import "core:fmt"
import "core:os"
import "core:strings"
import "solutions/day00"
import "solutions/day01"
import "solutions/day02"
import "solutions/day03"
import "solutions/day04"
import "solutions/day05"
import "solutions/day06"
import "solutions/day07"
import "solutions/day08"
import "solutions/day09"
import "solutions/day10"
import "solutions/day11"
import "solutions/day12"
import "solutions/day13"
import "solutions/day14"
import "solutions/day15"
import "solutions/day16"
import "solutions/day17"
import "solutions/day18"
import "solutions/day19"
import "solutions/day20"
import "solutions/day21"
import "solutions/day22"
import "solutions/day23"
import "solutions/day24"
import "solutions/day25"

Solver :: #type proc(input: [][]u8) -> int

main :: proc() {

	solvers := make(map[string][2]Solver)
	defer {
		delete(solvers)
	}
	solvers["00"] = {day00.part1, day00.part2}
	solvers["01"] = {day01.part1, day01.part2}
	solvers["02"] = {day02.part1, day02.part2}
	solvers["03"] = {day03.part1, day03.part2}
	solvers["04"] = {day04.part1, day04.part2}
	solvers["05"] = {day05.part1, day05.part2}
	solvers["06"] = {day06.part1, day06.part2}
	solvers["07"] = {day07.part1, day07.part2}
	solvers["08"] = {day08.part1, day08.part2}
	solvers["09"] = {day09.part1, day09.part2}
	solvers["10"] = {day10.part1, day10.part2}
	solvers["11"] = {day11.part1, day11.part2}
	solvers["12"] = {day12.part1, day12.part2}
	solvers["13"] = {day13.part1, day13.part2}
	solvers["14"] = {day14.part1, day14.part2}
	solvers["15"] = {day15.part1, day15.part2}
	solvers["16"] = {day16.part1, day16.part2}
	solvers["17"] = {day17.part1, day17.part2}
	solvers["18"] = {day18.part1, day18.part2}
	solvers["19"] = {day19.part1, day19.part2}
	solvers["20"] = {day20.part1, day20.part2}
	solvers["21"] = {day21.part1, day21.part2}
	solvers["22"] = {day22.part1, day22.part2}
	solvers["23"] = {day23.part1, day23.part2}
	solvers["24"] = {day24.part1, day24.part2}
	solvers["25"] = {day25.part1, day25.part2}

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
		solver_proc = solvers[day][0]
	} else {
		solver_proc = solvers[day][1]
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
