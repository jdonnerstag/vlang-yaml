module ystrconv

fn test_int() ? {
	assert is_int('1') == true
	assert is_int('12') == true
	assert is_int('+1') == true
	assert is_int('+121') == true
	assert is_int('-3') == true
	assert is_int('-32') == true

	assert is_int('1a') == false
	assert is_int('a') == false
	assert is_int('a1') == false
	assert is_int('') == false
}

fn test_float() ? {
	assert is_float('1') == true
	assert is_float('12') == true
	assert is_float('+1') == true
	assert is_float('+121') == true
	assert is_float('-3') == true
	assert is_float('-32') == true
	assert is_float('.1') == true
	assert is_float('1.1') == true
	assert is_float('1.') == true
	assert is_float('1.1e2') == true
	assert is_float('1.1e+2') == true
	assert is_float('1.1e-2') == true
	assert is_float('1.1E12') == true

	assert is_float('1a') == false
	assert is_float('a') == false
	assert is_float('a1') == false
	assert is_float('') == false
	assert is_float('1,1') == false
	assert is_float('1.1a') == false
	assert is_float('1.1e3a') == false
	assert is_float('1.1e*3') == false
	assert is_float('1.1e2.2') == false
}
