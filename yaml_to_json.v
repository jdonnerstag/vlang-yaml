module yaml

import strings
import os
import json

// YamlJson This is mostly an internal struct to namespace some functions.
pub struct YamlJson {
	tokens []YamlToken
}

// yaml_to_json convert YAML content into a JSON string
pub fn yaml_to_json(content string, args NewTokenizerParams) ?string {
	tokenizer := yaml_tokenizer(content, args) ?

	mut json := YamlJson{
		tokens: tokenizer.tokens
	}

	return json.yaml_to_json_root(args.debug)
}

// yaml_file_to_json Read the yaml file and convert it to JSON string
pub fn yaml_file_to_json(fpath string, args NewTokenizerParams) ?string {
	content := os.read_file(fpath) ?
	return yaml_to_json(content, args)
}

// yaml_to_json_root Main entry point for converting the YAML tokens
// into a JSON string
pub fn (mut json YamlJson) yaml_to_json_root(debug int) ?string {
	if debug > 1 {
		eprintln('-------- yaml_to_json')
	}

	mut str := strings.new_builder(4000)
	mut pos := 0
	for pos < json.tokens.len {
		tok := json.tokens[pos]
		if debug > 1 {
			eprintln("pos: $pos, type: $tok.typ, val: '$tok.val'")
		}
		if tok.typ == YamlTokenKind.start_list {
			pos = json.yaml_to_json_list_parent(pos + 1, mut str, debug) ?
		} else if tok.typ == YamlTokenKind.start_object {
			pos = json.yaml_to_json_map_parent(pos + 1, mut str, debug) ?
		} else if tok.typ == YamlTokenKind.value {
			str.write_string(tok.val.format())
		} else if tok.typ == YamlTokenKind.close {
			// ignore
		} else if tok.typ == YamlTokenKind.end_of_document {
			break
		} else if tok.typ == YamlTokenKind.new_document {
			// ignore
		} else if tok.typ == YamlTokenKind.tag_def {
			// ignore
		} else {
			str.write_string(tok.val.format())
		}

		pos += 1
	}

	if debug > 1 {
		eprintln('-------- yaml_to_json finished')
	}
	return str.str()
}

fn (mut json YamlJson) yaml_to_json_list_parent(idx int, mut str strings.Builder, debug int) ?int {
	str.write_byte(`[`)
	mut pos := idx
	for pos < json.tokens.len {
		tok := json.tokens[pos]
		if debug > 1 {
			eprintln("pos: $pos, type: $tok.typ, val: '$tok.val'")
		}
		if tok.typ == YamlTokenKind.start_list {
			if pos > idx {
				str.write_string(', ')
			}
			pos = json.yaml_to_json_list_parent(pos + 1, mut str, debug) ?
		} else if tok.typ == YamlTokenKind.start_object {
			if pos > idx {
				str.write_string(', ')
			}
			pos = json.yaml_to_json_map_parent(pos + 1, mut str, debug) ?
		} else if tok.typ == YamlTokenKind.value {
			if pos > idx {
				str.write_string(', ')
			}
			str.write_string(tok.val.format())
		} else if tok.typ == YamlTokenKind.tag_ref {
			if str.len > 0 {
				str.write_string(', ')
			}
			x := tok.val.format()
			str.write_string('"*')
			str.write_string(x[1..])
		} else if tok.typ == YamlTokenKind.close {
			str.write_byte(`]`)
			break
		} else if tok.typ == YamlTokenKind.end_of_document {
			break
		} else if tok.typ == YamlTokenKind.tag_def {
			// ignore
		} else {
			// ignore
		}

		pos += 1
	}

	return pos
}

fn (mut json YamlJson) yaml_to_json_map_parent(idx int, mut str strings.Builder, debug int) ?int {
	str.write_byte(`{`)
	mut pos := idx
	for pos < json.tokens.len {
		tok := json.tokens[pos]
		if debug > 1 {
			eprintln("pos: $pos, type: $tok.typ, val: '$tok.val'")
		}
		if tok.typ == YamlTokenKind.start_list {
			pos = json.yaml_to_json_list_parent(pos + 1, mut str, debug) ?
		} else if tok.typ == YamlTokenKind.start_object {
			pos = json.yaml_to_json_map_parent(pos + 1, mut str, debug) ?
		} else if tok.typ == YamlTokenKind.key {
			if pos > idx {
				str.write_string(', ')
			}
			x := tok.val.format()
			if x.len > 0 && x[0] in [`"`, `'`] {
				str.write_string(x)
				str.write_string(': ')
			} else {
				str.write_byte(`"`)
				str.write_string(x)
				str.write_string('": ')
			}
		} else if tok.typ == YamlTokenKind.value {
			str.write_string(tok.val.format())
		} else if tok.typ == YamlTokenKind.tag_ref {
			x := tok.val.format()
			str.write_string('"*')
			str.write_string(x[1..])
		} else if tok.typ == YamlTokenKind.close {
			str.write_byte(`}`)
			break
		} else if tok.typ == YamlTokenKind.end_of_document {
			break
		} else if tok.typ == YamlTokenKind.tag_def {
			// ignore
		} else {
			// ignore
		}

		pos += 1
	}

	return pos
}
