import yaml
import os

fn main() {
	if os.args.len != 2 {
		eprintln('Usage: yaml2json <yaml-file>')
		exit(1)
	}

	fname := os.args[1]
	if os.is_file(fname) != true {
		eprintln('File not found: $fname')
		exit(1)
	}

	str := yaml.yaml_to_json(fname, replace_tags: true, debug: 0) ?
	println(str)
}
