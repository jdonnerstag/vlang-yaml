module ystrconv

// import regex

/*
const (
	re_int = regex.regex_opt("[+-]?[0-9]+") or { panic("Invalid regex: 're_int'") }

	// V's "simplified" regex implementation is useless. The following simple
	// regex doesn't work.
	re_float = regex.regex_opt("[-+]?([0-9]*[.])?[0-9]+([eE][-+]?[0-9]+)?") or { panic("Invalid regex: 're_float'") }
)
*/

// regex.regex_opt("[+-]?[0-9]+")?
fn p_is_int_(str string, i int) int {
	mut pos := i
	for pos < str.len {
		ch := str[pos]
		if ch.is_digit() == false {
			break
		}
		pos++
	}
	return pos
}

fn optional_char(str string, pos int, ch u8) int {
	if str.len > 0 && str[pos] == ch {
		return pos + 1
	}
	return pos
}

fn optional_char_in(str string, pos int, bytes string) int {
	if pos < str.len && str[pos] in bytes.bytes() {
		return pos + 1
	}
	return pos
}

// regex.regex_opt("[+-]?[0-9]+")?
fn p_is_int(str string) int {
	if str[0] == `0` && str.len > 1 {
		return 0
	}
	mut pos := optional_char_in(str, 0, '+-')
	return p_is_int_(str, pos)
}

// regex.regex_opt("[-+]?([0-9]*[.])?[0-9]+([eE][-+]?[0-9]+)?")?
fn p_is_float(str string) int {
	if str[0] == `0` && str.len > 1 && str[1] != `.` { // TODO: parse `octal` & `hex`
		return 0
	}
	mut pos := optional_char_in(str, 0, '+-')

	{
		marker := pos
		pos = p_is_int_(str, pos)
		if pos < str.len && str[pos] == `.` {
			pos++
		} else {
			pos = marker
		}
	}
	pos = p_is_int_(str, pos)

	{
		pos2 := optional_char_in(str, pos, 'eE')
		if pos != pos2 {
			pos = optional_char_in(str, pos2, '+-')
		}
		pos = p_is_int_(str, pos)
	}
	return pos
}

pub fn is_int(str string) bool {
	return str.len > 0 && p_is_int(str) == str.len
}

pub fn is_float(str string) bool {
	return str.len > 0 && p_is_float(str) == str.len
}

/*
pub fn is_int(str string) bool {
	mut re := re_int
	start, stop := re.match_string(str)
	return str.len > 0 && start == 0 && stop == str.len
}

pub fn is_float(str string) bool {
	mut re := re_float
	start, stop := re.match_string(str)
	return str.len > 0 && start == 0 && stop == str.len
}
*/
