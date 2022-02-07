module yaml

// ---------------------------------------------------------------
// Some weird array behavior
// ---------------------------------------------------------------

type XValue = XListValue | string

struct XListValue {
pub mut:
	ar []int
}

// I think there is a bug in V's array implementation when it comes
// to pointer elements
fn test_array_append_failing() ? {
	mut ar := []&XValue{} // []&XValue{}	// A list of XValue pointers
	mut x := XListValue{}
	mut px := &x // Get a pointer to the 'x' XValue
	ar << px // Append the pointer to the list

	x.ar << 9 // Modify 'x'.

	assert x.ar.len == 1
	assert x.ar[0] == 9

	assert px.ar.len == 1
	assert px.ar[0] == 9

	// eprintln("x: $x")
	// eprintln("ar: $ar")	// ????

	a0 := ar.last() // pointer to 'x'
	if a0 is XListValue {
		/*
		assert a0.ar.len == 1	// wrong ???
		assert a0.ar[0] == 9	// wrong ???
		*/
	}
}

fn test_array_append_workaround_sollution() ? {
	mut ar := []voidptr{} // []&XValue{}	// A list of XValue pointers
	mut x := XListValue{}
	mut px := &x // Get a pointer to the 'x' XValue

	ar << px // Append the pointer to the list

	x.ar << 9 // Modify 'x'.

	assert x.ar.len == 1
	assert x.ar[0] == 9

	assert px.ar.len == 1
	assert px.ar[0] == 9

	// eprintln("x: $x")
	// eprintln("ar: $ar")

	px = ar.last()
	a0 := XValue(*px)
	if a0 is XListValue {
		assert a0.ar.len == 1
		assert a0.ar[0] == 9
	}
}

// ---------------------------------------------------------------
// next() for iterations
// ---------------------------------------------------------------

struct MyData {
pub mut:
	pos int
}

fn (mut this MyData) next() ?int {
	x := this.pos
	this.pos++
	return x
}

fn test_next() {
	x := MyData{}
	mut j := 0
	for i in x {
		j = i
		if i > 9 {
			break
		}
	}
	assert j == 10
}

// ---------------------------------------------------------------
// What happens to functions in embedded structs
// ---------------------------------------------------------------

struct Aa {
mut:
	a int
}

fn (a Aa) get_a() int {
	return a.a
}

struct Bb {
	Aa
mut:
	b string
}

fn test_embedded_structs() {
	// ??? It is not possible to use embedded vars in constructor
	// b := Bb{ a: 2, b: "test" }

	mut b := Bb{
		b: 'test'
	}
	b.a = 2
	assert b.a == 2
	assert b.b == 'test'

	// It is not mentioned in the documentation, but it seems that also the methods
	// defined for the embedded struct can be used.
	assert b.get_a() == 2
}

// ---------------------------------------------------------------
// Issue with array being past
// ---------------------------------------------------------------

struct MyData1 {
pub mut:
	ar []int
}

fn pass_array_mut(mut ar []int) int {
	if ar.len > 0 && ar[ar.len - 1] == 99 {
		// if ar.len > 0 && ar.last() == 99 {
		return 99
	}
	return 0
}

fn test_pass_array() {
	mut m := MyData1{}
	m.ar << 99
	assert pass_array_mut(mut m.ar) == 99
}
