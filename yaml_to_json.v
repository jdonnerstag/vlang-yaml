module yaml


// YamlJson This is mostly an internal struct to namespace some functions.
struct YamlJson {
	tokens []YamlToken
pub mut:
	json string
}

// yaml_to_json Read the yaml file and convert it into a JSON string
pub fn yaml_to_json(fpath string, args NewTokenizerParams) ?string {
	tokenizer := yaml_tokenizer(fpath, args)?

	mut json := YamlJson { tokens: tokenizer.tokens }

	return json.yaml_to_json_root(args.debug)
}

// yaml_to_json_root Main entry point for converting the YAML tokens
// into a JSON string 
fn (mut json YamlJson) yaml_to_json_root(debug int) ?string {

	if debug > 1 { eprintln("-------- yaml_to_json") }
	mut str := ""
	mut astr := ""
	mut pos := 0
	for pos < json.tokens.len {
		tok := json.tokens[pos]
		if debug > 1 { eprintln("pos: $pos, type: $tok.typ, val: '$tok.val'") }
		if tok.typ == YamlTokenKind.start_list { 
			str += "["
			pos, astr = json.yaml_to_json_list_parent(pos + 1, debug)?
			str += astr
		} else if tok.typ == YamlTokenKind.start_object { 
			str += "{"
			pos, astr = json.yaml_to_json_map_parent(pos + 1, debug)?
			str += astr
		} else if tok.typ == YamlTokenKind.value {
			str += tok.val.format()
		} else if tok.typ == YamlTokenKind.close {
			// ignore
		} else if tok.typ == YamlTokenKind.end_of_document { 
			break
		} else if tok.typ == YamlTokenKind.new_document { 
			// ignore
		} else if tok.typ == YamlTokenKind.tag_def { 
			// ignore
		} else {
			str += tok.val.format()
		}
	
		pos += 1
	}

	if debug > 1 { eprintln("-------- yaml_to_json finished") }
	return str
}

fn (mut json YamlJson) yaml_to_json_list_parent(idx int, debug int) ?(int, string) {

	mut str := ""
	mut astr := ""
	mut pos := idx
	for pos < json.tokens.len {
		tok := json.tokens[pos]
		if debug > 1 { eprintln("pos: $pos, type: $tok.typ, val: '$tok.val'") }
		if tok.typ == YamlTokenKind.start_list { 
			if str.len > 0 { str += ", " }
			str += "["
			pos, astr = json.yaml_to_json_list_parent(pos + 1, debug)?
			str += astr
		} else if tok.typ == YamlTokenKind.start_object { 
			if str.len > 0 { str += ", " }
			str += "{"
			pos, astr = json.yaml_to_json_map_parent(pos + 1, debug)?
			str += astr
		} else if tok.typ == YamlTokenKind.value {
			if str.len > 0 { str += ", " }
			str += tok.val.format()
		} else if tok.typ == YamlTokenKind.tag_ref {
			if str.len > 0 { str += ", " }
			x := tok.val.format()
			y := "\"*" + x[1 ..]
			str += y
		} else if tok.typ == YamlTokenKind.close {
			str += "]"
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

	return pos, str
}

fn (mut json YamlJson) yaml_to_json_map_parent(idx int, debug int) ?(int, string) {

	mut str := ""
	mut astr := ""
	mut pos := idx
	for pos < json.tokens.len {
		tok := json.tokens[pos]
		if debug > 1 { eprintln("pos: $pos, type: $tok.typ, val: '$tok.val'") }
		if tok.typ == YamlTokenKind.start_list { 
			str += "["
			pos, astr = json.yaml_to_json_list_parent(pos + 1, debug)?
			str += astr
		} else if tok.typ == YamlTokenKind.start_object { 
			str += "{"
			pos, astr = json.yaml_to_json_map_parent(pos + 1, debug)?
			str += astr
		} else if tok.typ == YamlTokenKind.key {
			if str.len > 0 { str += ", " }
			x := tok.val.format()
			if x.len > 0 && x[0] in [`"`, `'`] {
				str += "$x: "
			} else {
				str += "\"x\": "
			}
		} else if tok.typ == YamlTokenKind.value {
			str += tok.val.format()
		} else if tok.typ == YamlTokenKind.tag_ref {
			x := tok.val.format()
			y := "\"*" + x[1 ..]
			str += y
		} else if tok.typ == YamlTokenKind.close {
			str += "}"
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

	return pos, str
}
