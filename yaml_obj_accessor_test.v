module yaml

// YAML spec: https://yaml.org/spec/1.2/spec.html
// To test your YAML: https://www.json2yaml.com/
import os

const test_data_dir = os.dir(@FILE) + '/test_data'

const debug = 0

fn test_z_ex_01() ? {
	content := os.read_file('$test_data_dir/z_ex_01.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x := docs.get(0)
	assert x.get(0) ?.string() ? == 'Mark McGwire'
	assert x.get(1) ?.string() ? == 'Sammy Sosa'
	assert x.get(2) ?.string() ? == 'Ken Griffey'

	assert x.get() ?.is_list() == true
	assert x.get() ?.is_map() == false
	assert x.get() ?.is_value() == false
	assert x.get() ?.len() == 3
	assert x.get() ?.is_empty() == false
}

fn test_z_ex_02() ? {
	content := os.read_file('$test_data_dir/z_ex_02.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x := docs.get(0)
	assert x.get('hr') ?.string() ? == '65'
	assert x.get('hr') ?.int() ? == 65
	assert x.get('avg') ?.string() ? == '0.278'
	assert x.get('avg') ?.f64() ? == 0.278
	assert x.get('rbi') ?.string() ? == '147'

	assert x.get('hr') ?.int() ? == 65

	assert x.get() ?.is_list() == false
	assert x.get() ?.is_map() == true
	assert x.get() ?.is_value() == false
	assert x.get() ?.len() == 3
	assert x.get() ?.is_empty() == false

	assert x.get('hr') ?.int() ? == 65
	assert x.get('hr') ?.int() ? == 65

	assert x.get('avg') ?.f64() ? == 0.278
	assert x.get('rbi') ?.u32() ? == 147
	assert x.get('rbi') ?.u16() ? == 147
	assert x.get('rbi') ?.u8() ? == 147
}

fn test_z_ex_03() ? {
	content := os.read_file('$test_data_dir/z_ex_03.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x := docs.get(0)
	assert x.get('american', 0) ?.string() ? == 'Boston Red Sox'
	assert x.get('american', 1) ?.string() ? == 'Detroit Tigers'
	assert x.get('american', 2) ?.string() ? == 'New York Yankees'

	assert x.get('national', 0) ?.string() ? == 'New York Mets'
	assert x.get('national', 1) ?.string() ? == 'Chicago Cubs'
	assert x.get('national', 2) ?.string() ? == 'Atlanta Braves'
}

fn test_z_ex_04() ? {
	content := os.read_file('$test_data_dir/z_ex_04.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1.get(0, 'name') ?.string() ? == 'Mark McGwire'
	assert x1.get(0, 'hr') ?.string() ? == '65'
	assert x1.get(0, 'avg') ?.string() ? == '0.278'

	assert x1.get(1, 'name') ?.string() ? == 'Sammy Sosa'
	assert x1.get(1, 'hr') ?.string() ? == '63'
	assert x1.get(1, 'avg') ?.string() ? == '0.288'
}

fn test_z_ex_05() ? {
	content := os.read_file('$test_data_dir/z_ex_05.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)

	assert x1.get(0, 0) ?.string() ? == 'name'
	assert x1.get(0, 1) ?.string() ? == 'hr'
	assert x1.get(0, 2) ?.string() ? == 'avg'

	assert x1.get(1, 0) ?.string() ? == 'Mark McGwire'
	assert x1.get(1, 1) ?.string() ? == '65'
	assert x1.get(1, 2) ?.string() ? == '0.278'

	assert x1.get(2, 0) ?.string() ? == 'Sammy Sosa'
	assert x1.get(2, 1) ?.string() ? == '63'
	assert x1.get(2, 2) ?.string() ? == '0.288'
}

fn test_z_ex_06() ? {
	content := os.read_file('$test_data_dir/z_ex_06.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)

	assert x1.get('Mark McGwire', 'hr') ?.string() ? == '65'
	assert x1.get('Mark McGwire', 'avg') ?.string() ? == '0.278'

	assert x1.get('Sammy Sosa', 'hr') ?.string() ? == '63'
	assert x1.get('Sammy Sosa', 'avg') ?.string() ? == '0.288'
}

fn test_z_ex_07() ? {
	content := os.read_file('$test_data_dir/z_ex_07.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 2

	x1 := docs.get(0)
	assert x1.get(0) ?.string() ? == 'Mark McGwire'
	assert x1.get(1) ?.string() ? == 'Sammy Sosa'
	assert x1.get(2) ?.string() ? == 'Ken Griffey'

	x2 := docs.get(1)
	assert x2.get(0) ?.string() ? == 'Chicago Cubs'
	assert x2.get(1) ?.string() ? == 'St Louis Cardinals'
}

fn test_z_ex_08() ? {
	content := os.read_file('$test_data_dir/z_ex_08.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 2

	x1 := docs.get(0)
	assert x1.get('time') ?.string() ? == '20:03:20'
	assert x1.get('player') ?.string() ? == 'Sammy Sosa'
	assert x1.get('action') ?.string() ? == 'strike (miss)'

	x2 := docs.get(1)
	assert x2.get('time') ?.string() ? == '20:03:47'
	assert x2.get('player') ?.string() ? == 'Sammy Sosa'
	assert x2.get('action') ?.string() ? == 'grand slam'
}

fn test_z_ex_09() ? {
	content := os.read_file('$test_data_dir/z_ex_09.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('hr', 0) ?.string() ? == 'Mark McGwire'
	assert x1.get('hr', 1) ?.string() ? == 'Sammy Sosa'

	assert x1.get('rbi', 0) ?.string() ? == 'Sammy Sosa'
	assert x1.get('rbi', 1) ?.string() ? == 'Ken Griffey'
}

fn test_z_ex_10() ? {
	content := os.read_file('$test_data_dir/z_ex_10.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('hr', 0) ?.string() ? == 'Mark McGwire'
	assert x1.get('hr', 1) ?.string() ? == 'Sammy Sosa'

	assert x1.get('rbi', 0) ?.string() ? == 'Sammy Sosa'
	assert x1.get('rbi', 1) ?.string() ? == 'Ken Griffey'
}

fn test_z_ex_11() ? {
	content := os.read_file('$test_data_dir/z_ex_11.yaml') ?

	// Complex mapping keys are not supported
	if _ := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) {
		assert false
	}
}

fn test_z_ex_12() ? {
	content := os.read_file('$test_data_dir/z_ex_12.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get(0, 'item') ?.string() ? == 'Super Hoop'
	assert x1.get(0, 'quantity') ?.string() ? == '1'

	assert x1.get(1, 'item') ?.string() ? == 'Basketball'
	assert x1.get(1, 'quantity') ?.string() ? == '4'

	assert x1.get(2, 'item') ?.string() ? == 'Big Shoes'
	assert x1.get(2, 'quantity') ?.string() ? == '1'
}

fn test_z_ex_13() ? {
	content := os.read_file('$test_data_dir/z_ex_13.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get() ?.string() ? == '\\//||\\/||\n// ||  ||__'
}

fn test_z_ex_14() ? {
	content := os.read_file('$test_data_dir/z_ex_14.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get() ?.string() ? == "Mark McGwire's year was crippled by a knee injury."
}

fn test_z_ex_15() ? {
	content := os.read_file('$test_data_dir/z_ex_15.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get() ?.string() ? == 'Sammy Sosa completed another fine season with great stats.\n\n  63 Home Runs\n  0.288 Batting Average\n\nWhat a year!'
}

fn test_z_ex_16() ? {
	content := os.read_file('$test_data_dir/z_ex_16.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('name') ?.string() ? == 'Mark McGwire'
	assert x1.get('accomplishment') ?.string() ? == 'Mark set a major league home run record in 1998.'
	assert x1.get('stats') ?.string() ? == '65 Home Runs\n0.278 Batting Average\n'
}

fn test_z_ex_17() ? {
	content := os.read_file('$test_data_dir/z_ex_17.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('unicode') ?.string() ? == 'Sosa did fine.☺'
	assert x1.get('control') ?.string() ? == '\b1998\t1999\t2000\n'
	assert x1.get('hex esc') ?.string() ? == '\r\n is \r\n'
	assert x1.get('single') ?.string() ? == '"Howdy!" he cried.'
	assert x1.get('quoted') ?.string() ? == " # Not a 'comment'."
	assert x1.get('tie-fighter') ?.string() ? == '|\\-*-/|'
}

fn test_z_ex_18() ? {
	content := os.read_file('$test_data_dir/z_ex_18.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('plain 1') ?.string() ? == 'This unquoted scalar spans many lines. It has three lines.'
	assert x1.get('plain 2') ?.string() ? == 'This is also multi-line'
	assert x1.get('plain 3') ?.string() ? == 'The second line is more indented'
	assert x1.get('plain 4') ?.string() ? == 'The third line is more indented'
	assert x1.get('plain 5') ?.string() ? == 'This is another example that should work'
	assert x1.get('plain 6') ?.string() ? == 'The second line\nis more indented'

	assert x1.get('quoted') ?.string() ? == 'So does this quoted scalar with.\n'
}

fn test_z_ex_19() ? {
	content := os.read_file('$test_data_dir/z_ex_19.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('canonical') ?.string() ? == '12345'
	assert x1.get('decimal') ?.int() ? == 12345
	assert x1.get('octal') ?.int() ? == 12
	assert x1.get('hexadecimal') ?.int() ? == 12
}

fn test_z_ex_20() ? {
	content := os.read_file('$test_data_dir/z_ex_20.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('canonical') ?.f64() ? == 1.23015e+3
	assert x1.get('exponential') ?.f64() ? == 12.3015e+02
	assert x1.get('fixed') ?.f64() ? == 1230.15
	assert x1.get('negative infinity') ?.string() ? == '-.inf'
	assert x1.get('not a number') ?.string() ? == '.NaN'
}

fn test_z_ex_21() ? {
	content := os.read_file('$test_data_dir/z_ex_21.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('null') ?.string() ? == ''
	assert x1.get('string') ?.string() ? == '012345'
	assert x1.get('booleans', 0) ?.string() ? == 'true'
	assert x1.get('booleans', 1) ?.string() ? == 'false'
}

fn test_z_ex_22() ? {
	content := os.read_file('$test_data_dir/z_ex_22.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('canonical') ?.string() ? == '2001-12-15T02:59:43.1Z'
	assert x1.get('iso8601') ?.string() ? == '2001-12-14t21:59:43.10-05:00'
	assert x1.get('spaced') ?.string() ? == '2001-12-14 21:59:43.10 -5'
	assert x1.get('date') ?.string() ? == '2002-12-14'
}

fn test_z_ex_23() ? {
	content := os.read_file('$test_data_dir/z_ex_23.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('not-date') ?.string() ? == '2002-04-28'
	assert x1.get('picture') ?.string() ? == 'R0lGODlhDAAMAIQAAP//9/X\n17unp5WZmZgAAAOfn515eXv\nPz7Y6OjuDg4J+fn5OTk6enp\n56enmleECcgggoBADs=\n'
	assert x1.get('application specific tag') ?.string() ? == 'The semantics of the tag\nabove may be different for\ndifferent documents.\n'
}

fn test_z_ex_24() ? {
	content := os.read_file('$test_data_dir/z_ex_24.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get(0, 'center', 'x') ?.int() ? == 73
	assert x1.get(0, 'center', 'y') ?.int() ? == 129
	assert x1.get(0, 'radius') ?.int() ? == 7

	assert x1.get(1, 'start', 'x') ?.string() ? == '73'
	assert x1.get(1, 'start', 'y') ?.string() ? == '129'
	assert x1.get(1, 'finish', 'x') ?.string() ? == '89'
	assert x1.get(1, 'finish', 'y') ?.string() ? == '102'

	assert x1.get(2, 'start', 'x') ?.string() ? == '73'
	assert x1.get(2, 'start', 'y') ?.string() ? == '129'
	assert x1.get(2, 'color') ?.int() ? == 0xFFEEBB
	assert x1.get(2, 'text') ?.string() ? == 'Pretty vector drawing.'
}

fn test_z_ex_25() ? {
	content := os.read_file('$test_data_dir/z_ex_25.yaml') ?
	if _ := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) {
		assert false
	}
	// '?' is not yet support
	/*
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug)?
	assert docs.documents.len == 1
	x := rtn[0]
	assert x is YamlMapValue
	if x is YamlMapValue {
		assert x.obj.len == 3
		assert x.obj["hr"] == YamlValue("65")
		assert x.obj["avg"] == YamlValue("0.278")
		assert x.obj["rbi"] == YamlValue("147")
	}
	*/
}

fn test_z_ex_26() ? {
	content := os.read_file('$test_data_dir/z_ex_26.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get(0, 'Mark McGwire') ?.string() ? == '65'
	assert x1.get(1, 'Sammy Sosa') ?.string() ? == '63'
	assert x1.get(2, 'Ken Griffy') ?.string() ? == '58'
}

fn test_z_ex_27() ? {
	content := os.read_file('$test_data_dir/z_ex_27.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('invoice') ?.string() ? == '34843'
}

fn test_nested_objects() ? {
	content := os.read_file('$test_data_dir/nested_objects.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1

	x1 := docs.get(0)
	assert x1.get('aaa') ?.string() ? == 'string'
	assert x1.get('bbb', '111') ?.string() ? == '1-1-1'
	assert x1.get('ccc', '222') ?.string() ? == ''
	assert x1.get('ccc', '223') ?.string() ? == 'xxx'
}

//
