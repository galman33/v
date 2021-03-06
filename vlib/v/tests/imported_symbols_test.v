module main

import geometry { Point, Line, Shape, point_str, module_name }

fn test_imported_symbols_types() {
    // struct init
    p0 := Point{x: 10 y: 20}
    p1 := Point{x: 40 y: 60}
    // array init
    l0 := Line {
        ps: [p0, p1]
    }
    assert l0.ps[0].y == 20
}

fn test_imported_symbols_functions() {
	p0 := Point{x: 20 y: 40}
	// method
	assert p0.str() == '20 40'
	// function
    assert point_str(p0) == '20 40'
}

fn test_imported_symbols_constants() {
	assert module_name == 'geometry'
}

fn vertex_count(s Shape) int {
	return match s {
		.circle { 0 }
		.triangle { 3 }
		.rectangle { 4 }
	}
}

fn test_imported_symbols_enums() {
	assert vertex_count(.triangle) == 3
	assert vertex_count(Shape.triangle) == 3
}
