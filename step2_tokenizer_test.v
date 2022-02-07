module yaml

// YAML spec: https://yaml.org/spec/1.2/spec.html
// To test your YAML: https://www.json2yaml.com/
import os

const test_data_dir = os.dir(@FILE) + '/test_data'

const debug = 0

fn test_is_quoted() ? {
	assert is_quoted('', `'`) == false
	assert is_quoted('a', `'`) == false
	assert is_quoted('aa', `'`) == false
	assert is_quoted('aaa', `'`) == false
	assert is_quoted("a'b'", `'`) == false
	assert is_quoted("'a'b", `'`) == false
	assert is_quoted("'ab'", `'`) == true
	assert is_quoted("'a'", `'`) == true
	assert is_quoted("''", `'`) == true
	assert is_quoted("''", `"`) == false
	assert is_quoted('"ab"', `"`) == true
	assert is_quoted('"a"', `"`) == true
	assert is_quoted('""', `"`) == true
}

fn test_remove_quotes() ? {
	assert remove_quotes('') ? == ''
	assert remove_quotes('a') ? == 'a'
	assert remove_quotes('aa') ? == 'aa'
	assert remove_quotes('aaa') ? == 'aaa'
	assert remove_quotes("a'b'") ? == "a'b'"
	assert remove_quotes("'a'b") ? == "'a'b"
	assert remove_quotes("'ab'") ? == 'ab'
	assert remove_quotes("'a'") ? == 'a'
	assert remove_quotes("''") ? == ''
	assert remove_quotes('"ab"') ? == 'ab'
	assert remove_quotes('"a"') ? == 'a'
	assert remove_quotes('""') ? == ''
}

fn test_to_value_type() ? {
	assert to_value_type('') ? == YamlTokenValueType('')
	assert to_value_type('a') ? == YamlTokenValueType('a')
	assert to_value_type('aa') ? == YamlTokenValueType('aa')
	assert to_value_type('aaa') ? == YamlTokenValueType('aaa')
	assert to_value_type("a'b'") ? == YamlTokenValueType("a'b'")
	assert to_value_type("'a'b") ? == YamlTokenValueType("'a'b")
	assert to_value_type("'ab'") ? == YamlTokenValueType('ab')
	assert to_value_type("'a'") ? == YamlTokenValueType('a')
	assert to_value_type("''") ? == YamlTokenValueType('')
	assert to_value_type('"ab"') ? == YamlTokenValueType('ab')
	assert to_value_type('"a"') ? == YamlTokenValueType('a')
	assert to_value_type('""') ? == YamlTokenValueType('')

	assert to_value_type('1') ? == YamlTokenValueType(i64(1))
	assert to_value_type('+1') ? == YamlTokenValueType(i64(1))
	assert to_value_type('-1') ? == YamlTokenValueType(i64(-1))
	assert to_value_type('100') ? == YamlTokenValueType(i64(100))

	assert to_value_type('1.') ? == YamlTokenValueType(f64(1))
	assert to_value_type('1.1') ? == YamlTokenValueType(f64(1.1))
	assert to_value_type('.1') ? == YamlTokenValueType(f64(0.1))
	assert to_value_type('1e2') ? == YamlTokenValueType(f64(100))
	assert to_value_type('10e+2') ? == YamlTokenValueType(f64(1000))
	assert to_value_type('10e-2') ? == YamlTokenValueType(f64(.1))

	assert to_value_type('450.00') ? == YamlTokenValueType(f64(450))
	assert to_value_type('2392.00') ? == YamlTokenValueType(f64(2392))

	assert to_value_type('true') ? == YamlTokenValueType(true)
	assert to_value_type('false') ? == YamlTokenValueType(false)
	assert to_value_type('yes') ? == YamlTokenValueType(true)
	assert to_value_type('no') ? == YamlTokenValueType(false)
	assert to_value_type('0') ? == YamlTokenValueType(i64(0))
	assert to_value_type('1') ? == YamlTokenValueType(i64(1))
}

fn test_z_ex_10_resolve_tags() ? {
	content := os.read_file('$test_data_dir/z_ex_10.yaml') ?
	tokenizer := yaml_tokenizer(content, replace_tags: true, debug: debug) ?
	assert tokenizer.tags.len == 1
	assert tokenizer.tokens.len == 14
	assert tokenizer.tokens[5] == tokenizer.tokens[9] // "SS" tag
	// for i, tok in tokenizer.tokens { eprintln("$i: $tok") }
}

fn test_z_ex_24_resolve_tags() ? {
	content := os.read_file('$test_data_dir/z_ex_24.yaml') ?
	tokenizer := yaml_tokenizer(content, replace_tags: true, debug: debug) ?
	assert tokenizer.tags.len == 1
	assert tokenizer.tokens.len == 44
	// for i, tok in tokenizer.tokens { eprintln("$i: $tok.typ, $tok.val") }
	assert tokenizer.tokens[4] == tokenizer.tokens[15] // 1. "ORIGIN" tag
	assert tokenizer.tokens[4] == tokenizer.tokens[22] // 2. "ORIGIN" tag
}

fn test_z_ex_27_resolve_tags() ? {
	content := os.read_file('$test_data_dir/z_ex_27.yaml') ?
	tokenizer := yaml_tokenizer(content, replace_tags: true, debug: debug) ?
	assert tokenizer.tags.len == 1
	assert tokenizer.tokens.len == 73
	// for i, tok in tokenizer.tokens { eprintln("$i: $tok.typ, $tok.val") }
	assert tokenizer.tokens[8] == tokenizer.tokens[26] // "id001" tag
	assert tokenizer.tokens[15] == tokenizer.tokens[33]
}
