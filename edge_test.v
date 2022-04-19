module yaml

const debug = 0

fn test_edge() ? {
	content := '
a: 444***111
b: aiu [ true, false ] # comment
c: 09123112 # comment
octal_in_yaml1.1: 02123112 # comment
octal: 0o2123112 # comment
hex: 0x2123112 # comment
byte: 0b101101
d: 1-2 # comment
ee:   [ true, false ]
f:  null
e: 1
inv_quote: invalid"
90: a
arrow: it\'s cool yes -> no
double_quote: |
  yes "that" is that that that
double_quote_inline: "{\\"yey\\":true}"
time: 11:30
time2: 23:37
time_inv: 25:30
'
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x := docs.get(0)
	assert x is YamlMapValue
	if x is YamlMapValue {
		assert x.obj.len == 19
		// eprintln(x.ar)
		// dump(x.obj['d'] ?)
		// dump(x.obj['e'] ?)
		// dump(x.obj['f'] ?)
		dump(x.obj['arrow'] ?)
		// dump(x.obj['b'])
		// assert x.obj['a'] == YamlValue("444***111")
		// assert x.obj['b'] == YamlValue("aiu [ true, false ]")
		// assert x.obj['c'] == YamlValue("02123112")
	}
	assert x.get('a') ?.string() ? == '444***111'
	assert x.get('b') ?.string() ? == 'aiu [ true, false ]'
	assert x.get('c') ?.type_name() == 'string'
	assert x.get('c') ?.string() ? == '09123112'
	assert x.get('octal') ?.i64() ? == 566858
	$if yaml_1_1_octal ? {
		assert x.get('octal_') ?.i64() ? == 566858
	} $else {
		assert x.get('octal_in_yaml1.1') ?.string() ? == '02123112'
	}
	assert x.get('hex') ?.i64() ? == 34746642
	assert x.get('byte') ?.i64() ? == 45
	assert x.get('d') ?.type_name() == 'string'
	assert x.get('d') ?.string() ? == '1-2'
	assert x.get('inv_quote') ?.string() ? == 'invalid"'
	assert x.get('time') ?.string() ? == '11:30'
	assert x.get('time2') ?.string() ? == '23:37'
	assert x.get('time_inv') ?.string() ? == '25:30'
	assert x.get('arrow') ?.string() ? == "it's cool yes -> no"
	assert x.get('double_quote') ?.string() ? == 'yes "that" is that that that'
	assert x.get('double_quote_inline') ?.string() ? == '{"yey":true}'
	assert x.get('90') ?.string() ? == 'a'
	assert x.get('f') ?.type_name() == 'yaml.Null'
	assert x.get('f') ? == YamlValue(null)
	// assert x.get('d')?.type_name() == "string"
	assert (x.get('ee') ? as YamlListValue).ar == [YamlValue(true), false]
	assert x.get('e') ?.i64() ? == 1
	assert x.get('f') ? is Null
}
