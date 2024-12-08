package day08

import "core:fmt"
import "core:os"
import "core:strings"


part1 :: proc(input: [][]u8) -> int {
	ans := 0
	height, width := len(input), len(input[0])
	antinodes := make([][]bool, height)
	for &line in antinodes {
		line = make([]bool, width)
	}
	antennas: map[u8][dynamic][2]int
	defer {
		for line in antinodes {
			delete(line)
		}
		delete(antinodes)
		for k, locations in antennas {
			delete(locations)
		}
		delete(antennas)
	}
	for line, i in input {
		for c, j in line {
			switch c {
			case 'A' ..= 'Z', 'a' ..= 'z', '0' ..= '9':
				locations: [dynamic][2]int
				if c in antennas {
					locations = antennas[c]
				}
				append(&locations, [2]int{i, j})
				antennas[c] = locations
			}
		}
	}
	for _, locations in antennas {
		for p1 in locations {
			for p2 in locations {
				if p1 == p2 {
					continue
				}
				diff := p1 - p2
				pos := p1 + diff
				if pos.x >= 0 && pos.x < height && pos.y >= 0 && pos.y < width {
					antinodes[pos.x][pos.y] = true
				}
			}
		}
	}
	for line in antinodes {
		for c in line {
			if c {
				ans += 1
			}
		}
	}
	return ans
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	height, width := len(input), len(input[0])
	antinodes := make([][]bool, height)
	for &line in antinodes {
		line = make([]bool, width)
	}
	antennas: map[u8][dynamic][2]int
	defer {
		for line in antinodes {
			delete(line)
		}
		delete(antinodes)
		for k, locations in antennas {
			delete(locations)
		}
		delete(antennas)
	}
	for line, i in input {
		for c, j in line {
			switch c {
			case 'A' ..= 'Z', 'a' ..= 'z', '0' ..= '9':
				locations: [dynamic][2]int
				if c in antennas {
					locations = antennas[c]
				}
				append(&locations, [2]int{i, j})
				antennas[c] = locations
			}
		}
	}
	for _, locations in antennas {
		for p1 in locations {
			for p2 in locations {
				if p1 == p2 {
					continue
				}
				antinodes[p1.x][p1.y] = true
				antinodes[p2.x][p2.y] = true
				diff := p1 - p2
				pos := p1 + diff
				for pos.x >= 0 && pos.x < height && pos.y >= 0 && pos.y < width {
					antinodes[pos.x][pos.y] = true
					pos += diff
				}
			}
		}
	}
	for line in antinodes {
		for c in line {
			if c {
				ans += 1
			} else {
			}
		}
	}
	return ans
}
