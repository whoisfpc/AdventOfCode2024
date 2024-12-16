package utils

make_2d :: proc(height, width: int, $E: typeid) -> [][]E {
	s2 := make([][]E, height)
	for &line in s2 {
		line = make([]E, width)
	}
	return s2
}

destroy_2d :: proc(s2: $T/[][]$E) {
	for line in s2 {
		delete(line)
	}
	delete(s2)
}
