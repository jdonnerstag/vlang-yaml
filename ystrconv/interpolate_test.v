module ystrconv

import encoding.utf8

fn test_char_to_base() ? {
	assert char_to_base(`0`, 8) ? == 0
	assert char_to_base(`0`, 10) ? == 0
	assert char_to_base(`0`, 16) ? == 0

	assert char_to_base(`7`, 8) ? == 7
	assert char_to_base(`7`, 10) ? == 7
	assert char_to_base(`7`, 16) ? == 7

	if _ := char_to_base(`8`, 8) { assert false }
	assert char_to_base(`8`, 10) ? == 8
	assert char_to_base(`8`, 16) ? == 8

	if _ := char_to_base(`A`, 8) { assert false }
	if _ := char_to_base(`A`, 10) { assert false }
	assert char_to_base(`A`, 16) ? == 10

	if _ := char_to_base(`a`, 8) { assert false }
	if _ := char_to_base(`a`, 10) { assert false }
	assert char_to_base(`a`, 16) ? == 10

	if _ := char_to_base(`F`, 8) { assert false }
	if _ := char_to_base(`F`, 10) { assert false }
	assert char_to_base(`F`, 16) ? == 15

	if _ := char_to_base(`G`, 8) { assert false }
	if _ := char_to_base(`G`, 10) { assert false }
	if _ := char_to_base(`G`, 16) { assert false }
}

fn test_parse_number_fix_length() ? {
	assert parse_number_fix_length('\\000', 1, 3, 8) ? == i64(0)
	assert parse_number_fix_length('\\001', 1, 3, 8) ? == i64(1)
	assert parse_number_fix_length('\\010', 1, 3, 8) ? == i64(8)
	assert parse_number_fix_length('\\100', 1, 3, 8) ? == i64(64)
	assert parse_number_fix_length('\\111', 1, 3, 8) ? == i64(73)
	assert parse_number_fix_length('\\111abc', 1, 3, 8) ? == i64(73)
	assert parse_number_fix_length('a\\111', 2, 3, 8) ? == i64(73)

	assert parse_number_fix_length('\\x00', 2, 2, 16) ? == i64(0)
	assert parse_number_fix_length('\\x01', 2, 2, 16) ? == i64(1)
	assert parse_number_fix_length('\\x10', 2, 2, 16) ? == i64(16)
	assert parse_number_fix_length('\\x11', 2, 2, 16) ? == i64(17)
	assert parse_number_fix_length('\\xff', 2, 2, 16) ? == i64(255)
	assert parse_number_fix_length('\\xFF', 2, 2, 16) ? == i64(255)

	assert parse_number_fix_length('\\x11', 2, 2, 16) ? == i64(17)
	assert parse_number_fix_length('\\x11abc', 2, 2, 16) ? == i64(17)
	assert parse_number_fix_length('a\\x11', 3, 2, 16) ? == i64(17)
}

fn test_int_to_bytes() ? {
	assert int_to_bytes(0) == [u8(0)]
	assert int_to_bytes(1) == [u8(1)]
	assert int_to_bytes(0xff) == [u8(0xff)]
	assert int_to_bytes(0x100) == [u8(0x1), 0]
	assert int_to_bytes(0x1000) == [u8(0x10), 0]
	assert int_to_bytes(0x1_0000) == [u8(0), 1, 0, 0]
	assert int_to_bytes(0x1000_0000) == [u8(0x10), 0, 0, 0]
	assert int_to_bytes(0x1_0000_0000) == [u8(0), 0, 0, 1, 0, 0, 0, 0]
	assert int_to_bytes(0x1_0000_0000_0000) == [u8(0), 1, 0, 0, 0, 0, 0, 0]
	assert int_to_bytes(0x1000_0000_0000_0000) == [u8(0x10), 0, 0, 0, 0, 0, 0, 0]
}

fn test_interpolate_double_quoted_string() ? {
	assert interpolate_double_quoted_string(r'') ? == ''
	assert interpolate_double_quoted_string(r'a') ? == 'a'
	assert interpolate_double_quoted_string(r'\n') ? == '\n'
	assert interpolate_double_quoted_string(r'\r') ? == '\r'
	assert interpolate_double_quoted_string(r'\t') ? == '\x09'
	assert interpolate_double_quoted_string(r"\'") ? == "'"
	assert interpolate_double_quoted_string(r'\"') ? == '"'
	assert interpolate_double_quoted_string(r'\?') ? == '?'
	assert interpolate_double_quoted_string(r'\123') ? == 'S'
	assert interpolate_double_quoted_string(r'\123\124') ? == 'ST'
	assert interpolate_double_quoted_string(r'\123ABC') ? == 'SABC'
	assert interpolate_double_quoted_string(r'\x00') ? == '\000'
	assert interpolate_double_quoted_string(r'\x40') ? == '@'
	assert interpolate_double_quoted_string(r'\x40abc\123') ? == '@abcS'
	assert interpolate_double_quoted_string(r'\u0040') ? == '@'

	assert '௵' == '\u0BF5'
	assert '௵'.bytes() == [u8(0xe0), 0xaf, 0xb5]
	assert '\u0BF5'.bytes() == [u8(0xe0), 0xaf, 0xb5]
	assert utf8.get_uchar('௵', 0) == 0x0bf5
	assert utf8_char_len('௵'[0]) == 3
	assert utf32_to_str(0x0BF5).bytes() == [u8(0xe0), 0xaf, 0xb5]
	assert interpolate_double_quoted_string(r'\u0BF5') ? == '௵'

	assert interpolate_double_quoted_string(r"This is a ''comment''") ? == "This is a ''comment''"
}

fn test_interpolate_single_quoted_string() ? {
	assert interpolate_single_quoted_string(r'') == ''
	assert interpolate_single_quoted_string(r'a') == 'a'
	assert interpolate_single_quoted_string(r'\n') == '\\n'
	assert interpolate_single_quoted_string(r'\r') == '\\r'
	assert interpolate_single_quoted_string(r'\t') == '\\t'
	assert interpolate_single_quoted_string(r"\'") == "\\'"
	assert interpolate_single_quoted_string(r'\"') == '\\"'
	assert interpolate_single_quoted_string(r'\?') == '\\?'
	assert interpolate_single_quoted_string(r'\123') == '\\123'
	assert interpolate_single_quoted_string(r'\123\124') == '\\123\\124'
	assert interpolate_single_quoted_string(r'\123ABC') == '\\123ABC'
	assert interpolate_single_quoted_string(r'\x00') == '\\x00'
	assert interpolate_single_quoted_string(r'\x40') == '\\x40'
	assert interpolate_single_quoted_string(r'\x40abc\123') == '\\x40abc\\123'
	assert interpolate_single_quoted_string(r'\u0040') == '\\u0040'

	assert '௵' == '\u0BF5'
	assert '௵'.bytes() == [u8(0xe0), 0xaf, 0xb5]
	assert '\u0BF5'.bytes() == [u8(0xe0), 0xaf, 0xb5]
	assert utf8.get_uchar('௵', 0) == 0x0bf5
	assert utf8_char_len('௵'[0]) == 3
	assert utf32_to_str(0x0BF5).bytes() == [u8(0xe0), 0xaf, 0xb5]
	assert interpolate_single_quoted_string(r'\u0BF5') == '\\u0BF5'

	// This is the only thing happening
	assert interpolate_single_quoted_string(r"This is a ''comment''") == "This is a 'comment'"
}

fn test_interpolate_plain_value() ? {
	assert interpolate_plain_value('abc') == 'abc'
	assert interpolate_plain_value('123') == '123'

	assert interpolate_plain_value('0x1') == '1'
	assert interpolate_plain_value('0x12') == '18'
	assert interpolate_plain_value('0x123') == '291'
	assert interpolate_plain_value('ab0x11') == 'ab0x11'
	assert interpolate_plain_value('0x11Test') == '0x11Test'

	assert interpolate_plain_value('0o1') == '1'
	assert interpolate_plain_value('0o12') == '10'
	assert interpolate_plain_value('0o123') == '83'
	assert interpolate_plain_value('0o1Test') == '0o1Test'

	assert interpolate_plain_value('0b1') == '1'
	assert interpolate_plain_value('0b10') == '2'
	assert interpolate_plain_value('0b101') == '5'
	assert interpolate_plain_value('0b1Test') == '0b1Test'
}
