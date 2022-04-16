module ystrconv

import math
import strings

pub fn char_to_base(ch u8, base int) ?int {
	mut i := int(ch)
	if ch >= `0` && ch < (`0` + math.min(base, 10)) {
		i = i - int(`0`)
	} else if ch >= `A` && ch < (`A` + base - 10) {
		i = i - int(`A`) + 10
	} else if ch >= `a` && ch < (`a` + base - 10) {
		i = i - int(`a`) + 10
	} else {
		return error("Invalid digit for number with base $base: '$ch'")
	}
	return i
}

pub fn parse_number_fix_length(str string, pos int, len int, base int) ?i64 {
	if (pos + len) <= str.len {
		mut rtn := i64(0)
		for i in pos .. (pos + len) {
			ch := str[i]
			x := char_to_base(ch, base) ?
			rtn = (rtn * i64(base)) + i64(x)
		}
		return rtn
	}
	return error("Invalid length. Expected $len more chars: '${str[pos..]}'")
}

pub fn parse_number_variable_length(str string, pos int, base int) ?i64 {
	mut rtn := i64(0)
	for ch in str[pos..] {
		x := char_to_base(ch, base) ?
		rtn = (rtn * i64(base)) + i64(x)
	}
	return rtn
}

pub fn int_to_bytes(i i64) []u8 {
	if i < 0x0100 {
		return [u8(i)]
	}

	a := u8((i >> 0) & 0xff)
	b := u8((i >> 8) & 0xff)
	if i < 0x1_0000 {
		return [b, a]
	}

	c := u8((i >> 16) & 0xff)
	d := u8((i >> 24) & 0xff)
	if i < 0x1_0000_0000 {
		return [d, c, b, a]
	}

	e := u8((i >> 32) & 0xff)
	f := u8((i >> 40) & 0xff)
	g := u8((i >> 48) & 0xff)
	h := u8((i >> 56) & 0xff)
	return [h, g, f, e, d, c, b, a]
}

pub fn interpolate_double_quoted_string(val string) ?string {
	if val.contains('\\') == false {
		return val
	}

	mut str := strings.new_builder(val.len)
	mut pos := 0
	for pos < val.len {
		ch := val[pos]
		if ch == `\\` && (pos + 1) < val.len {
			x := val[pos + 1]
			if x == `a` { str.write_byte(0x07) }
			else if x == `b` { str.write_byte(0x08) }
			else if x == `e` { str.write_byte(0x1b) }
			else if x == `f` { str.write_byte(0x0c) }
			else if x == `n` { str.write_byte(0x0a) }
			else if x == `r` { str.write_byte(0x0d) }
			else if x == `t` { str.write_byte(0x09) }
			else if x == `v` { str.write_byte(0x0b) }
			else if x == `x` {
				str.write_string(int_to_bytes(parse_number_fix_length(val, pos + 2, 2,
					16) ?).bytestr())
				pos += 2
			} else if x == `u` {
				cp := parse_number_fix_length(val, pos + 2, 4, 16) ?
				str.write_rune(rune(u32(cp)))
				pos += 4
			} else if x == `U` {
				cp := parse_number_fix_length(val, pos + 2, 8, 16) ?
				str.write_rune(rune(u32(cp)))
				pos += 8
			} else if x >= `0` && x < `8` {
				str.write_string(int_to_bytes(parse_number_fix_length(val, pos + 1, 3,
					8) ?).bytestr())
				pos += 2
			} else {
				// Has no special meaning
				str.write_byte(val[pos + 1])
			}
			pos++
		} else {
			str.write_byte(val[pos])
		}
		pos++
	}

	return str.str()
}

// interpolate_single_quoted_string  In Yaml single quoted strings are used
// when unescaping is not what you want. The only exception being '', which
// will be replaced with a single quote, e.g. 'this is a ''test'''
pub fn interpolate_single_quoted_string(val string) string {
	return val.replace("''", "'")
}

// interpolate_plain_value
// 0x1A
// 0o12
// 0b1100100
pub fn interpolate_plain_value(str string) string {
	$if test {
		assert str.len > 1
	}
	mut base := 10
	mut prefix_len := 0
	if str[0] == `0` {
		if str[1] == `x` && str.len > 2 {
			base = 16
			prefix_len = 2
		} else if str[1] == `o` && str.len > 2 {
			base = 8
			prefix_len = 2
		} else if str[1] == `b` && str.len > 2 {
			base = 2
			prefix_len = 2
		} else {
			$if yaml_1_1_octal ? {
				if str.len > 1 {
					for i in 1 .. str.len {
						if str[i] < `0` || str[i] > `7` {
							return str
						}
					}
					base = 8
					prefix_len = 1
				} else {
					return str
				}
			} $else {
				return str
			}
		}

		x := parse_number_variable_length(str, prefix_len, base) or { return str }

		return x.str()
	} else {
		return str
	}
}
