package day14

import "core:fmt"
import "core:image"
import "core:image/bmp"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:text/regex"

V2 :: [2]int

height :: 103
width :: 101

Robot :: struct {
	pos: V2,
	vel: V2,
}

part1 :: proc(input: [][]u8) -> int {
	ans := 0
	regex_robot, robot_err := regex.create("p=(\\d+),(\\d+) v=(-*\\d+),(-*\\d+)", {})
	assert(robot_err == nil)
	defer regex.destroy(regex_robot)

	all_robots := make([dynamic]Robot)
	defer delete(all_robots)

	for line in input {
		cap_a, ok_a := regex.match(regex_robot, transmute(string)line)
		assert(ok_a)
		defer regex.destroy(cap_a)

		px, _ := strconv.parse_int(cap_a.groups[1])
		py, _ := strconv.parse_int(cap_a.groups[2])
		vx, _ := strconv.parse_int(cap_a.groups[3])
		vy, _ := strconv.parse_int(cap_a.groups[4])

		r := Robot {
			pos = {px, py},
			vel = {vx, vy},
		}
		append(&all_robots, r)
	}

	for &r in all_robots {
		np := (r.pos + r.vel * 100) % V2{width, height}
		if np.x < 0 {
			np.x += width
		}
		if np.y < 0 {
			np.y += height
		}
		r.pos = np
		// fmt.println(r)
	}
	// print_grid(all_robots)
	mx, my := width / 2, height / 2
	f1, f2, f3, f4 := 0, 0, 0, 0
	for r in all_robots {
		if r.pos.x < mx && r.pos.y < my {
			f1 += 1
		} else if r.pos.x > mx && r.pos.y < my {
			f2 += 1
		} else if r.pos.x < mx && r.pos.y > my {
			f3 += 1
		} else if r.pos.x > mx && r.pos.y > my {
			f4 += 1
		}
	}
	ans = f1 * f2 * f3 * f4
	return ans
}

print_grid :: proc(all_robots: [dynamic]Robot) {
	for y in 0 ..< height {
		for x in 0 ..< width {
			n := 0
			for r in all_robots {
				n += 1 if r.pos == V2{x, y} else 0
			}
			if n == 0 {
				fmt.print(".")
			} else {
				fmt.print(n)
			}
		}
		fmt.println()
	}
}

check_easter_egg :: proc(all_robots: [dynamic]Robot) -> bool {
	for y in 0 ..< height {
		for x in 0 ..< width {
			n := 0
			for r in all_robots {
				n += 1 if r.pos == V2{x, y} else 0
			}
			if n > 0 {
				return false
			}
		}
	}
	return true
}

create_robots_image :: proc(all_robots: [dynamic]Robot, pixels: []image.RGBA_Pixel, number: int) {
	for r in all_robots {
		idx := r.pos.y * width + r.pos.x
		pixels[idx] = image.RGBA_Pixel{255, 255, 255, 255}
	}
	img, ok := image.pixels_to_image(pixels, width, height)
	assert(ok)
	sb, _ := strings.builder_make()
	defer strings.builder_destroy(&sb)
	filename := fmt.sbprintf(&sb, "day14imgs/img%v.bmp", number)
	save_err := bmp.save_to_file(filename, &img)
	if save_err != nil {
		fmt.println("error", save_err)
		fmt.println("save filename", filename)
	}
	assert(save_err == nil)
}

part2 :: proc(input: [][]u8) -> int {
	ans := 0
	regex_robot, robot_err := regex.create("p=(\\d+),(\\d+) v=(-*\\d+),(-*\\d+)", {})
	assert(robot_err == nil)
	defer regex.destroy(regex_robot)

	all_robots := make([dynamic]Robot)
	defer delete(all_robots)

	for line in input {
		cap_a, ok_a := regex.match(regex_robot, transmute(string)line)
		assert(ok_a)
		defer regex.destroy(cap_a)

		px, _ := strconv.parse_int(cap_a.groups[1])
		py, _ := strconv.parse_int(cap_a.groups[2])
		vx, _ := strconv.parse_int(cap_a.groups[3])
		vy, _ := strconv.parse_int(cap_a.groups[4])

		r := Robot {
			pos = {px, py},
			vel = {vx, vy},
		}
		append(&all_robots, r)
	}

	pixels := make([]image.RGBA_Pixel, width * height)
	defer delete(pixels)
	// create_robots_image(all_robots)
	// my answer is 6870
	start_idx, end_idx := 6870, 6870
	for ans < end_idx {
		ans += 1
		for &r in all_robots {
			np := (r.pos + r.vel) % V2{width, height}
			if np.x < 0 {
				np.x += width
			}
			if np.y < 0 {
				np.y += height
			}
			r.pos = np
		}
		if ans >= start_idx && ans <= end_idx {
			slice.zero(pixels)
			create_robots_image(all_robots, pixels, ans)
		}
	}
	return ans
}
