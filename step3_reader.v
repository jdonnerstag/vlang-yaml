module yaml

import text_scanner as ts

// Even though the compiler is able to handle this, and smart-cast
// does not raise a compiler error, it is not possible to access the
// array in the if-clause, e.g. if x is []YamlValue { assert x.len == 3 }
// does not work!!! Putting them into a struct is a workaround.
// type YamlValue = map[string]YamlValue | []YamlValue | string
pub type YamlValue = Null | YamlListValue | YamlMapValue | bool | f64 | i64 | string

pub struct Null {}

pub const null = Null{}

pub struct YamlListValue {
pub mut:
	ar []YamlValue
}

pub struct YamlMapValue {
pub mut:
	obj map[string]YamlValue
}

pub struct YamlValues {
pub:
	text     string       // The full yaml document
	newline  string       // The auto-detected newline
	encoding ts.Encodings // Currently only utf-8 is supported
pub mut:
	documents []YamlValue // The list of YAML documents. Often there is just one.

	tags map[string]YamlValue
}

[inline]
pub fn (val YamlValues) get(idx int) YamlValue {
	return val.documents[idx]
}

pub enum ReplaceTagsEnum {
	do_not
	in_tokenizer
	in_reader
}

pub struct NewYamlReaderParams {
	debug        int // 4 and 8 are good number to print increasingly more debug messages
	replace_tags ReplaceTagsEnum = ReplaceTagsEnum.in_reader
}

// yaml_reader This is the main function to read a YAML file and convert
// the YAML data into 'objects'. In V structs must be defined at compile
// time, and V [attributes] are not user extensible. V's json implementation
// makes use of attributes. Without a better option at hand, the implementation
// dynamically creates a tree structure leveraging a sumtype.
pub fn yaml_reader(content string, args NewYamlReaderParams) ?YamlValues {
	replace_tags_in_tokenizer := args.replace_tags == ReplaceTagsEnum.in_tokenizer
	tokenizer := yaml_tokenizer(content, replace_tags: replace_tags_in_tokenizer, debug: args.debug) ?

	mut values := YamlValues{
		text: tokenizer.text
		newline: tokenizer.newline
		encoding: tokenizer.encoding
	}

	values.read_root(tokenizer.tokens, args.debug) ?

	return values
}

// to_yamlvalue Convert a YamlTokenValueTyoe to a YamlValue
fn (v YamlTokenValueType) to_yamlvalue() YamlValue {
	/*
	TODO There is bug in the V compiler. This one should actually work, but creates invalid C code
	return match v {
		string { YamlValue(v) }
		i64 { YamlValue(v) }
		f64 { YamlValue(v) }
	}
	*/
	if v is string {
		a := v
		if a == 'null' {
			return null
		}
		return YamlValue(a)
	} else if v is i64 {
		a := v
		return YamlValue(a)
	} else if v is f64 {
		a := v
		return YamlValue(a)
	} else if v is bool {
		a := v
		return YamlValue(a)
	}
	panic('Will not happen')
}

// read_root Entry point to convert yaml tokens into yam values
fn (mut values YamlValues) read_root(tokens []YamlToken, debug int) ? {
	if debug > 1 {
		eprintln('-------- yaml_reader')
	}
	mut pos := 0
	for pos < tokens.len {
		tok := tokens[pos]
		if debug > 1 {
			eprintln("pos: $pos, type: $tok.typ, val: '$tok.val'")
		}
		if tok.typ == YamlTokenKind.start_list {
			mut obj := YamlListValue{}
			pos += values.read_with_list_parent(tokens[pos + 1..], mut obj, debug) ?
			values.documents << obj
		} else if tok.typ == YamlTokenKind.start_object {
			mut obj := YamlMapValue{}
			pos += values.read_with_map_parent(tokens[pos + 1..], mut obj, debug) ?
			values.documents << obj
		} else if tok.typ == YamlTokenKind.value {
			values.documents << tok.val.to_yamlvalue()
		} else if tok.typ == YamlTokenKind.end_of_document {
			// ignore
		} else if tok.typ == YamlTokenKind.new_document {
			// ignore
		} else if tok.typ == YamlTokenKind.tag_def {
			return error("Found tag definition on top level (document): '$tok.val'")
		} else {
			return error('Unexpected token: $tok')
		}

		pos += 1
	}

	if debug > 1 {
		eprintln('-------- yaml_reader: output generated')
		eprintln(values.documents)
		eprintln('tags:')
		eprintln(values.tags)
	}
}

// read_with_list_parent Assuming the parent is a list, then handle
// now all its elements
fn (mut values YamlValues) read_with_list_parent(tokens []YamlToken, mut parent YamlListValue, debug int) ?int {
	mut pos := 0
	mut tag := ''
	for pos < tokens.len {
		tok := tokens[pos]
		if debug > 1 {
			eprintln("pos: $pos, type: $tok.typ, val: '$tok.val'")
		}
		if tok.typ == YamlTokenKind.start_list {
			mut obj := YamlListValue{}
			pos += values.read_with_list_parent(tokens[pos + 1..], mut obj, debug) ?
			parent.ar << obj
		} else if tok.typ == YamlTokenKind.start_object {
			mut obj := YamlMapValue{}
			pos += values.read_with_map_parent(tokens[pos + 1..], mut obj, debug) ?
			parent.ar << obj
		} else if tok.typ == YamlTokenKind.value {
			obj := tok.val.to_yamlvalue()
			parent.ar << obj
			if tag.len > 0 {
				values.tags[tag] = obj
				tag = ''
			}
		} else if tok.typ == YamlTokenKind.key {
			return error("Did not expected a 'key' in a list context")
		} else if tok.typ == YamlTokenKind.close {
			break
		} else if tok.typ == YamlTokenKind.end_of_document {
			break
		} else if tok.typ == YamlTokenKind.new_document {
			break
		} else if tok.typ == YamlTokenKind.tag_def {
			tag = tok.val.str()
		} else if tok.typ == YamlTokenKind.tag_ref {
			obj := values.tags[tok.val.str()] ?
			parent.ar << obj
		} else {
			return error('Unexpected token: $tok')
		}

		pos += 1
	}

	return pos + 1
}

fn (mut values YamlValues) add_tag(tag string, obj YamlValue) {
	if tag.len > 0 {
		values.tags[tag] = obj
	}
}

// read_with_map_parent Assuming the parent is a map, then handle
// now all its elements
fn (mut values YamlValues) read_with_map_parent(tokens []YamlToken, mut parent YamlMapValue, debug int) ?int {
	mut key := ''
	mut pos := 0
	mut tag := ''
	for pos < tokens.len {
		tok := tokens[pos]
		if debug > 1 {
			eprintln("pos: $pos, type: $tok.typ, val: '$tok.val'")
		}
		if tok.typ == YamlTokenKind.start_list {
			mut obj := YamlListValue{}
			pos += values.read_with_list_parent(tokens[pos + 1..], mut obj, debug) ?
			parent.obj[key] = obj
			key = ''
			values.add_tag(tag, obj)
			tag = ''
		} else if tok.typ == YamlTokenKind.start_object {
			mut obj := YamlMapValue{}
			pos += values.read_with_map_parent(tokens[pos + 1..], mut obj, debug) ?
			parent.obj[key] = obj
			key = ''
			values.add_tag(tag, obj)
			tag = ''
		} else if tok.typ == YamlTokenKind.value {
			obj := tok.val.to_yamlvalue()
			parent.obj[key] = obj
			key = ''
			values.add_tag(tag, obj)
			tag = ''
		} else if tok.typ == YamlTokenKind.key {
			key = tok.val.str()
		} else if tok.typ == YamlTokenKind.close {
			break
		} else if tok.typ == YamlTokenKind.end_of_document {
			break
		} else if tok.typ == YamlTokenKind.new_document {
			break
		} else if tok.typ == YamlTokenKind.tag_def {
			tag = tok.val.str()
		} else if tok.typ == YamlTokenKind.tag_ref {
			parent.obj[key] = values.tags[tok.val.str()] ?
		} else {
			return error('Unexpected token: $tok')
		}

		pos += 1
	}

	if key.len > 0 {
		parent.obj[key] = YamlValue('')
	}

	return pos + 1
}
