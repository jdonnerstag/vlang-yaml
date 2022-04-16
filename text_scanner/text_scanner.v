module text_scanner

// text_scanner No matter whether you want to read CSV, JSON, YAML, etc.
// you often need a basic text scanner that tokenizes the text.
import os

struct TextScanner {
pub:
	text     string    // The full yaml document
	newline  string    // The auto-detected newline
	encoding Encodings // Currently only utf-8 is supported
pub mut:
	pos        int // The current scanner position within the file
	last_pos   int // The starting position of the current token
	line_no    int = 1 // The current line number
	column_pos int // Start-of-line position
}

pub fn read_file(fpath string, debug int) ?TextScanner {
	if debug > 2 {
		eprintln('YAML file: $fpath')
	}

	content := os.read_file(fpath) ?
	if debug > 2 {
		eprintln("content: \n'$content'")
	}

	return new_scanner(content)
}

pub fn new_scanner(data string) ?TextScanner {
	if data.len == 0 {
		return error('No YAML content. Data are empty.')
	}

	enc := detect_bom(data) or { Encodings.utf_8 }

	if enc != Encodings.utf_8 {
		return error("Currently the YAML reader only supports 'UTF-8'")
	}

	newline := detect_newline(data) or { '\n' }

	return TextScanner{
		pos: 0
		text: data
		encoding: enc
		newline: newline
	}
}

[inline]
pub fn (s TextScanner) len() int {
	return s.text.len
}

[inline]
pub fn (s TextScanner) is_eof() bool {
	return s.pos >= s.text.len
}

// at I wish V had more conventions, e.g. ar[idx] => ar.at(idx)
[inline]
pub fn (s TextScanner) at(pos int) u8 {
	return s.text[pos]
}

[inline]
pub fn (s TextScanner) at_pos() u8 {
	return s.text[s.pos]
}

[inline]
pub fn (mut s TextScanner) set_pos(pos int) {
	s.pos = pos
}

[inline]
pub fn is_newline(c u8) bool {
	return c in [`\n`, `\r`]
}

// detect_newline Auto-detect newline
pub fn detect_newline(str string) ?string {
	for i, c in str {
		if is_newline(c) {
			// CR LF (Windows), LF (Unix) and CR (Macintosh)
			len := if c == `\r` && (i + 1) < str.len && str[i + 1] == `\n` { 2 } else { 1 }
			return str[i..(i + len)]
		}
	}

	return none
}

pub fn (mut s TextScanner) on_newline() {
	s.skip(s.newline.len)

	s.line_no++
	s.column_pos = s.pos
}

// skip Move the position and mark it as being read
[inline]
pub fn (mut s TextScanner) skip(incr int) {
	s.pos += incr
	s.last_pos = s.pos
}

// skip Move the position only (do not mark it as being read)
[inline]
pub fn (mut s TextScanner) move(incr int) {
	s.pos += incr
}

// move_to_eol Move the position to next eol (or eof).
// Do not mark it as being read.
pub fn (mut s TextScanner) move_to_eol() {
	for s.pos < s.text.len {
		c := s.text[s.pos]
		if is_newline(c) {
			return
		}
		s.pos++
	}
}

// skip_to_eol Move the position to next eol (or eof)
// and mark it as being read.
pub fn (mut s TextScanner) skip_to_eol() {
	s.move_to_eol()
	s.last_pos = s.pos
}

// skip_whitespace Skip any whitespace, and mark it as being read.
pub fn (mut s TextScanner) skip_whitespace() {
	for s.pos < s.text.len {
		c := s.text[s.pos]
		if c.is_space() == false {
			s.last_pos = s.pos
			return
		}
		s.pos++
	}
}

// move_to_end_of_word Move the position to the character following
// the current word. A word separator is either space, newline or eof.
// Do not mark the text as being read.
pub fn (mut s TextScanner) move_to_end_of_word() int {
	for s.pos < s.text.len {
		c := s.text[s.pos]
		if c.is_space() || is_newline(c) {
			break
		}
		s.pos++
	}
	return s.pos
}

pub fn (mut s TextScanner) check_text() string {
	return s.text[s.last_pos..s.pos]
}

// get_text Retrieve the text from start_pos to the current position.
// Update last_pos (mark the text as being read)
pub fn (mut s TextScanner) get_text() string {
	str := s.text[s.last_pos..s.pos]
	s.last_pos = s.pos
	return str
}

pub fn (mut s TextScanner) at_str(len int) string {
	to := s.pos + len
	if to < s.text.len {
		return s.text[s.pos..s.pos + len]
	}
	return s.text[s.pos..]
}

// is_followed_by_space_or_eol Return true, if the current char is
// followed by either a space or newline, or eof.
pub fn (s TextScanner) is_followed_by_space_or_eol() bool {
	pos := s.pos + 1
	if pos >= s.text.len {
		return true
	}
	return s.text[pos] in [` `, `\r`, `\n`]
}

// is_followed_by Return true, if the current char is followed by char.
pub fn (s TextScanner) is_followed_by(c u8) bool {
	pos := s.pos + 1
	if pos >= s.text.len {
		return false
	}
	return s.text[pos] == c
}

// is_followed_by_word Return true if text at position starts with word,
// and is followed by either space, newline or eof.
pub fn (s TextScanner) is_followed_by_word(str string) bool {
	if s.text[s.pos..].starts_with(str) {
		pos := s.pos + str.len
		if pos >= s.text.len {
			return true
		}
		return s.text[pos] in [` `, `\r`, `\n`]
	}
	return false
}

// read_line From the current position read the rest of the line.
// Consider the data as being read.
pub fn (mut s TextScanner) read_line() string {
	s.move_to_eol()
	return s.get_text()
}

// substr A secure way to get a substring of the text.
// It properly considers lower and upper bound indices.
pub fn (s TextScanner) substr(pos int, len int) string {
	p := if pos < 0 { 0 } else { pos }
	if p >= s.text.len || len <= 0 {
		return ''
	}
	if (p + len) >= s.text.len {
		return s.text[p..]
	}
	return s.text[p..(p + len)] + '...'
}

// substr_escaped For printing escape special chars such CR and LF
pub fn (s TextScanner) substr_escaped(pos int, len int) string {
	mut str := s.substr(pos, len)
	return str_escaped(str)
}

// str_escaped For printing escape special chars such CR and LF
pub fn str_escaped(x string) string {
	mut str := x
	str = str.replace('\n', '\\n')
	str = str.replace('\r', '\\r')
	return str
}

// replace_nl_space Replace re"[\s\r\n]+" with " "
pub fn replace_nl_space(str string) string {
	mut rtn := []u8{cap: str.len + 1}
	mut count := 0
	for c in str {
		if c in [` `, `\n`, `\r`] {
			if count == 0 {
				rtn << ` `
				count++
			}
		} else {
			rtn << c
			count = 0
		}
	}
	return rtn.bytestr()
}

// quoted_string_scanner Scan strings quoted with either `"` or `'`
pub fn (mut s TextScanner) quoted_string_scanner(op fn (start_ch u8, str string) bool) ?string {
	start_ch := s.text[s.pos]
	line_no := s.line_no

	mut start_pos := s.pos
	s.skip(1)
	for s.pos < s.text.len {
		c := s.text[s.pos]
		if op(start_ch, s.text[s.pos..]) {
			s.move(2)
		} else if c == `\\` { // `"\"str"`
			s.move(2)
		} else if c == start_ch {
			s.skip(1)
			s.last_pos = start_pos
			return s.get_text() // We deliberately keep the quotes
		} else if is_newline(c) {
			s.on_newline()
		} else {
			s.move(1)
		}
	}

	return error("Closing quote `$start_ch.ascii_str()` missing. Starting at line $line_no: '${s.substr_escaped(s.pos - 10,
		20)}'")
}

// leading_spaces Determine the number of leading spaces (indentation)
pub fn leading_spaces(str string) int {
	for i, c in str {
		if c.is_space() == false {
			return i
		}
	}
	return str.len
}
