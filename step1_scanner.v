module yaml

import text_scanner as ts

struct Scanner {
pub mut:
	// TODO: There is a separate branch for embedded struct. Due to a V-bug, it can not be used right now.
	ts                ts.TextScanner // A somewhat generic text scanner
	beginning_of_line bool = true // True if we are *logically* at the beginning of a line
	tokens            []Token // YAML Tokens collected   TODO Keep for now, but remove ones next() is in place
	indent_level      []int = [1] // A stack of relevant indent levels
	debug             int     // The larger, the more debug messages. 4 and 9 are reasonable values.
	token_buffer      []Token
	block_levels      []u8 // Open block levels '{' or '['
}

pub enum TokenKind {
	lcbr // `{`
	rcbr // `}`
	labr // `[`
	rabr // `]`
	comma // `,`
	colon // `:`
	hyphen // `-`
	question_mark // `?`
	pipe // `|`
	greater // `>`
	newline // `\r`, `\n`
	document // `---`
	end_of_document // `...`
	xstr // anything else
	tag_url // Text starting with '!'
	tag_def // Text starting with '&'
	tag_ref // Text starting with '*'
	tag_directive // %TAG
}

pub struct Token {
	typ    TokenKind // Token type
	column int       // Token indent level
	val    string    // Token string value
}

struct ScannerIter {
mut:
	s Scanner
}

[inline]
pub fn (mut iter ScannerIter) next() ?Token {
	return iter.s.next_token()
}

[inline]
pub fn (s Scanner) scan() ScannerIter {
	return ScannerIter{
		s: s
	}
}

// This is basically a file reader and tokenizer. It's key properties are:
// - It splits the (file) content into a series of basic tokens, such as newline,
//   "-", ":", "{", "}", "[", etc.
// - It properly handles quoted text, such as ".." and also the variations of
//   multi-line text
// - Indentation plays a major role in YAML. Every token provide the indentation
//   level (== column)
pub fn yaml_scanner(content string, debug int) ?Scanner {
	if debug > 2 {
		eprintln("content: \n'$content'")
	}

	mut scanner := new_scanner(content, debug) ?

	// TODO Remove ones streaming properly works
	for tok in scanner.scan() {
		scanner.tokens << tok
	}
	return scanner
}

pub fn new_scanner(data string, debug int) ?Scanner {
	text_scanner := ts.new_scanner(data) ?
	return Scanner{
		ts: text_scanner
		debug: debug
	}
}

[inline]
pub fn (s Scanner) len() int {
	return s.ts.len()
}

// TODO rename fn. It no longer adds a token to something
fn (mut s Scanner) add_token(t_type TokenKind, val string) Token {
	tok := Token{
		typ: t_type
		column: s.indent_level.last()
		val: val
	}
	if s.debug > 7 {
		eprintln("new token: line-no: $s.ts.line_no, $s.indent_level, $t_type, '$val'")
	}
	return tok
}

fn (mut s Scanner) tokenize(t_type TokenKind, from int, to int) ?Token {
	x := if from >= s.ts.len() { '' } else { s.ts.text[from..to].trim_space() }
	if t_type != .xstr || x.len > 0 {
		return s.add_token(t_type, x)
	}
	return none
}

[inline]
fn (mut s Scanner) newline() {
	s.ts.on_newline()
	s.beginning_of_line = true
}

fn (mut s Scanner) to_token_kind(c u8) TokenKind {
	return match c {
		`{` { TokenKind.lcbr }
		`}` { TokenKind.rcbr }
		`[` { TokenKind.labr }
		`]` { TokenKind.rabr }
		`,` { TokenKind.comma }
		`:` { TokenKind.colon }
		`-` { TokenKind.hyphen }
		`?` { TokenKind.question_mark }
		`>` { TokenKind.greater }
		`|` { TokenKind.pipe }
		`\n` { TokenKind.newline }
		`\r` { TokenKind.newline }
		`!` { TokenKind.tag_url }
		`&` { TokenKind.tag_def }
		`*` { TokenKind.tag_ref }
		else { TokenKind.xstr }
	}
}

[inline]
fn (mut s Scanner) catch_up() ?Token {
	str := s.ts.get_text().trim_space()
	if str.len > 0 {
		tok := s.add_token(.xstr, str)
		return tok
	}
	return none
}

fn (mut s Scanner) new_indent_level_for_list(pos int) {
	if pos < 0 {
		// Remove all indent levels, except the first one
		for s.indent_level.len > 1 {
			s.indent_level.pop()
		}
		return
	}

	// Remove all indent levels, until 'column'
	col := pos - s.ts.column_pos + 2 // Column
	for (s.indent_level.len > 1) && (s.indent_level.last() >= col) {
		s.indent_level.pop()
	}

	// Add an indent level, if new level is greater then the latest one
	if s.indent_level.last() < col {
		s.indent_level << col
	}
}

fn (mut s Scanner) new_indent_level(pos int) {
	if pos < 0 {
		// Remove all indent levels, except the first one
		for s.indent_level.len > 1 {
			s.indent_level.pop()
		}
		return
	}

	// Remove all indent levels, until 'column'
	col := pos - s.ts.column_pos + 1 // Column
	for (s.indent_level.len > 1) && (s.indent_level.last() > col) {
		s.indent_level.pop()
	}

	// Add an indent level, if new level is greater then the latest one
	if s.indent_level.last() < col {
		s.indent_level << col
	}
}

fn (mut s Scanner) on_newline() Token {
	if tok := s.catch_up() {
		if tok.typ == .xstr {
			return s.plain_multi_line_scanner(s.ts.pos, tok)
		}
	}

	// Nothing found to catch up
	s.newline()
	return s.add_token(.newline, '')
}

[inline]
fn (mut s Scanner) add_to_token_buffer(tok Token) {
	s.token_buffer.prepend(tok)
}

// next_token This the main scanner implementation.
// Get the next token
fn (mut s Scanner) next_token() ?Token {
	if s.token_buffer.len > 0 {
		return s.token_buffer.pop()
	}

	if s.ts.is_eof() {
		return none
	}

	if s.block_levels.len > 0 {
		return s.block_scanner()
	}

	for !s.ts.is_eof() {
		c := s.ts.at_pos()
		if s.debug > 8 {
			eprintln("YAML: lineno: $s.ts.line_no, pos: $s.ts.pos, bol: $s.beginning_of_line, indent: $s.indent_level.last() ($s.indent_level.len), str='${s.ts.substr_escaped(s.ts.pos,
				20)}'")
		}

		// Some additional tokens/chars are considered only at the beginning of a line.
		// "Beginning of line" definition is a bit tricky: It is used to determine the
		// indent level. Usually it is the first non-space char, but in case of e.g.
		// "  - text", the indent level for "-" is 3 and for "text" it is 5.
		if s.beginning_of_line {
			if c == ` ` {
				s.ts.skip(1)
				continue
			} else if c == `\t` {
				return error("Tabs are not allowed for indentation. You must use spaces: '${s.ts.substr_escaped(s.ts.pos - 10,
					20)}'")
			} else if c in [`-`, `?`] && s.ts.is_followed_by_space_or_eol() { // list or set
				s.new_indent_level_for_list(s.ts.pos)
				tok := s.tokenize(s.to_token_kind(c), s.ts.pos, s.ts.pos + 1) ?
				s.ts.skip(1) // The next is optionally a space. It could as well be a newline
				return tok
			} else if s.ts.is_followed_by_word('---') { // beginning of document
				tok := s.tokenize(.document, s.ts.pos, s.ts.pos + 3) ?
				s.ts.skip(3)
				s.new_indent_level(-1) // close any open indent level
				return tok
			} else if s.ts.is_followed_by_word('...') { // end of document
				tok := s.tokenize(.end_of_document, s.ts.pos, s.ts.pos + 3) ?
				s.ts.skip(3)
				s.new_indent_level(-1) // close any open indent level
				return tok
			} else if s.ts.is_followed_by_word('%TAG') { // TAG directive
				str := s.ts.read_line()
				return s.add_token(.tag_directive, str)
			}
		}

		if c in [`"`, `'`] { // quoted strings
			if s.ts.check_text().trim_space().len > 0 {
				s.ts.move(1)
				continue
			}
			return s.quoted_string_scanner()
		} else if c in [`>`, `|`] { // (multi-line) flow text
			if s.ts.check_text().trim_space().len > 0 {
				s.ts.move(1)
				continue
			}
			return s.flow_string_scanner()
		} else if c == `#` { // Comment
			if tok := s.catch_up() {
				return tok
			}
			s.ts.skip_to_eol()
		} else if (c == `:`) && s.ts.is_followed_by_space_or_eol() { // key value separator: key: value
			if tok := s.catch_up() {
				return tok
			}
			tok := s.tokenize(.colon, s.ts.pos, s.ts.pos + 1) ?
			s.ts.skip(1)
			return tok
		} else if ts.is_newline(c) {
			return s.on_newline()
		} else if c in [`{`, `[`] {
			if s.ts.check_text().trim_space().len > 0 {
				s.ts.move(1)
				continue
			}
			return s.open_block(c)
		} else if c in [`!`, `&`, `*`] { // Tag related
			str0 := s.ts.check_text().trim_space()
			if str0.len > 0 {
				text := s.ts.read_line().trim_space()
				tok := s.add_token(.xstr, text)
				return tok
			}

			typ := s.to_token_kind(c)
			s.ts.skip(1) // Skip the leading char '!', '&', '*'
			s.ts.move_to_end_of_word()
			str := s.ts.get_text()
			tok := s.add_token(typ, str)
			return tok
		} else if c == `~` { // null
			str0 := s.ts.check_text()
			if str0.len > 1 {
				text := s.ts.read_line().trim_space()
				tok := s.add_token(.xstr, text)
				return tok
			}
		} else {
			if s.beginning_of_line {
				// This is the first non-space character
				// If required, adjust the indent level
				s.new_indent_level(s.ts.pos)
				s.beginning_of_line = false
			}
			s.ts.move(1)
		}
	}

	// Execute any outstanding (delayed) activities
	// Make sure that we always end with a newline
	tok := s.on_newline()
	if tok.typ != TokenKind.newline {
		s.add_to_token_buffer(s.on_newline())
	}

	return tok
}

fn (mut s Scanner) open_block(c u8) ?Token {
	mut typ := s.to_token_kind(c)
	tok := s.tokenize(typ, s.ts.pos, s.ts.pos + 1) ?

	s.block_levels << c
	s.ts.skip(1)

	return tok
}

// block_scanner Scan the '{..}'' and '[..]' sections
fn (mut s Scanner) block_scanner() ?Token {
	start_ch := s.block_levels.last() // The opening quote char

	for !s.ts.is_eof() {
		c := s.ts.at_pos()
		if c in [`{`, `[`] {
			return s.open_block(c)
		} else if c in [`}`, `]`] {
			if start_ch == `[` && c != `]` {
				return error('Bracket mismatch: $start_ch .. $c')
			}
			if start_ch == `{` && c != `}` {
				return error('Bracket mismatch: $start_ch .. $c')
			}
			if tok := s.catch_up() {
				return tok
			}
			s.block_levels.pop()
			tok := s.tokenize(s.to_token_kind(c), s.ts.pos, s.ts.pos + 1) ?
			s.ts.skip(1) // Position the pointer right after the closing bracket.
			return tok
		} else if ts.is_newline(c) {
			if tok := s.catch_up() {
				return tok
			}
			s.newline()
		} else if c in [`,`, `:`] {
			if tok := s.catch_up() {
				return tok
			}
			tok := s.tokenize(s.to_token_kind(c), s.ts.pos, s.ts.pos + 1) ?
			s.ts.skip(1)
			return tok
		} else if c in [`"`, `'`] {
			return s.quoted_string_scanner()
		} else if c == `#` {
			if tok := s.catch_up() {
				return tok
			}
			s.ts.skip_to_eol()
		} else {
			s.ts.move(1)
		}
	}
	return error("Missing closing bracket: '$start_ch'")
}

// quoted_string_scanner Scan strings quoted with either `"` or `'`
fn (mut s Scanner) quoted_string_scanner() ?Token {
	yaml_quoted_escapes := fn (start_ch u8, str string) bool {
		return start_ch == `'` && str.starts_with("''")
	}

	mut str := s.ts.quoted_string_scanner(yaml_quoted_escapes) ?
	str = ts.replace_nl_space(str)
	return s.add_token(.xstr, str)
}

// flow_string_scanner YAML has support for multi line flow text, triggered by
// either '|' or '>'. Multi-line PLAIN text exists as well and has no start
// indicator. Since the rules are quite different, plain text is handled
// elsewhere.
// The scanner position will be at the '|' or '>' char. A newline (or comment)
// must follow the start indicator.
fn (mut s Scanner) flow_string_scanner() ?Token {
	t_type := s.to_token_kind(s.ts.at(s.ts.pos))

	{ // Skip to end of line. Only comments are allowed.
		s.ts.skip(1)
		str := s.ts.read_line().trim_space()
		if str.len > 0 && str[0] !in [`#`, `-`] {
			return error("'|' and '>' must be followed by newline or a comment: '$str'")
		}
	}
	mut text := ''
	mut indent := 0
	mut nl := if t_type == TokenKind.greater { ' ' } else { '\n' }
	mut start_pos := 0

	for !s.ts.is_eof() {
		start_pos = s.ts.pos
		s.newline()

		str := s.ts.read_line()
		is_empty := str.trim_space().len == 0

		if text.len == 0 && is_empty == true {
			return error("First line of multi-line text must not be empty: '${s.ts.substr_escaped(s.ts.pos - 10,
				20)}'")
		}

		x := ts.leading_spaces(str)
		if indent == 0 && x > 0 {
			indent = x
		}

		// eprintln("is_empty: $is_empty, indent: $indent, x: $x, str: '$str'")
		lstr := if str.len >= indent { str[indent..] } else { '' }
		if text.len == 0 {
			text = lstr
		} else if is_empty == true {
			text += '\n' + lstr
			nl = '\n'
		} else if indent > 0 && x >= indent {
			text += nl + lstr
			if lstr.len == 0 || lstr[0].is_space() {
				nl = '\n'
			} else {
				nl = if t_type == TokenKind.greater { ' ' } else { '\n' }
			}
		} else {
			break
		}
	}

	if !s.ts.is_eof() {
		s.ts.set_pos(start_pos)
	}
	s.ts.skip(0)

	return s.add_token(.xstr, text)
}

// plain_multi_line_scanner This method is invoked at newline and if
// catch_up() returned an .xstr token. This is potentially the first
// line of a plain multi-line text.
// In any case an .xstr token will be returned. Either with the single
// line plain value, or the multi-line plain value.
// Upon return, the scanner position will be at the newline (or eof).
// IMHO YAML has quite some 'rules', which is also true for plain text.
// See https://yaml.org/spec/1.2/spec.html#id2788859 for more details.
fn (mut s Scanner) plain_multi_line_scanner(pos int, tok Token) Token {
	mut text := tok.val
	mut indent := tok.column - 1
	mut nl := ' '

	for !s.ts.is_eof() {
		// Remember the current position if the line is not
		// part of the multi-line
		start_pos := s.ts.pos
		s.newline()

		str := s.ts.read_line()

		trimmed := str.trim_space()
		empty := trimmed.len == 0
		x := ts.leading_spaces(str) // The indent level of the current line

		// See YAML spec: Empty lines or leading spaces, will trigger newline
		if empty == true {
			text += '\n'
			nl = ''
			continue
		} else {
			text += nl
			nl = ' '
		}

		// eprintln("plain: x: $x, indent: $indent, str: '${ts.str_escaped(str)}'")
		if x == 0 || x < indent || str.contains_any_substr(['- ', ': ', ' #']) || str.ends_with('-')
			|| str.ends_with(':') || str.starts_with('#') {
			s.ts.pos = start_pos
			s.ts.line_no--
			s.ts.skip(0)
			break
		} else {
			text += trimmed
		}
	}

	// See YAML spec for plain text: leading and trailing spaces are trimmed.
	text = text.trim_space()
	return Token{
		...tok
		val: text
	}
}
