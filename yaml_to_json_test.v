module yaml

// YAML spec: https://yaml.org/spec/1.2/spec.html
// To test your YAML: https://www.json2yaml.com/
import os
import regex
import json

const test_data_dir = os.dir(@FILE) + '/test_data'

const debug = 0

fn test_compare_with_json_files() ? {
	for f in os.ls('$test_data_dir/json') ? {
		if f.ends_with('.json') == false {
			continue
		}
		yf := '$test_data_dir/$f'.replace('.json', '.yaml')
		if os.is_file(yf) == false {
			continue
		}
		eprintln('read yaml: $yf')
		content := os.read_file(yf) ?
		json := yaml_to_json(content, replace_tags: true, debug: debug) ?

		file_content := os.read_file('$test_data_dir/json/$f') ?

		mut re := regex.regex_opt(',[\n\r]+\\s*') ?
		mut str := re.replace_simple(file_content, ', ')

		re = regex.regex_opt('[\n\r]+\\s*') ?
		str = re.replace_simple(str, '')

		str = str.replace('\\n', '\n')
		str = str.replace('\\r', '\r')
		str = str.replace('\\b', '\b')
		str = str.replace('\\t', '\t')

		eprintln(str)
		assert json == str
	}
}

fn read_json_file(fname string, debug int) ?string {
	content := os.read_file('$test_data_dir/${fname}.yaml') ?
	mut json_data := yaml_to_json(content, replace_tags: true, debug: debug) ?
	if json_data.starts_with('[') {
		return "{ \"ar\": $json_data }"
	}
	if json_data.starts_with('{') == false {
		return "{ \"val\": $json_data }"
	}
	return json_data
}

struct Zex01 {
	ar []string
}

fn test_z_ex_01() ? {
	mut json_data := read_json_file('z_ex_01', debug) ?
	// eprintln("$json_data")
	xj := json.decode(Zex01, json_data) ?
	assert xj.ar.len == 3
	assert xj.ar[0] == 'Mark McGwire'
	assert xj.ar[1] == 'Sammy Sosa'
	assert xj.ar[2] == 'Ken Griffey'
}

struct Zex02 {
	hr  int
	avg f64
	rbi int
}

fn test_z_ex_02() ? {
	mut json_data := read_json_file('z_ex_02', debug) ?
	// eprintln("$json_data")

	// The V built-in json parser is a little ..
	// - No exception if string is provided but the target is an 'int'. Instead 0 is returned.
	// - If the target is an 'int', then no quotes are allowed, e.g. "hr": "65" will not work. "hr": 65 does.
	xj := json.decode(Zex02, json_data) ?

	assert xj.hr == 65
	assert xj.avg == 0.278
	assert xj.rbi == 147
}

struct Zex03 {
	american []string
	national []string
}

fn test_z_ex_03() ? {
	mut json_data := read_json_file('z_ex_03', debug) ?
	// eprintln("$json_data")
	xj := json.decode(Zex03, json_data) ?

	assert xj.american.len == 3
	assert xj.american[0] == 'Boston Red Sox'
	assert xj.american[1] == 'Detroit Tigers'
	assert xj.american[2] == 'New York Yankees'

	assert xj.national.len == 3
	assert xj.national[0] == 'New York Mets'
	assert xj.national[1] == 'Chicago Cubs'
	assert xj.national[2] == 'Atlanta Braves'
}

struct Zex04_inner {
	name string
	hr   int
	avg  f64
}

struct Zex04 {
	ar []Zex04_inner
}

fn test_z_ex_04() ? {
	json_data := read_json_file('z_ex_04', debug) ?
	// eprintln("$json_data")
	xj := json.decode(Zex04, json_data) ?

	assert xj.ar.len == 2
}
