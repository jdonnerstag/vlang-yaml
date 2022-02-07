module yaml

const debug = 0

fn test_array_indent() ? {
	content := "
arr_indent:
- 1
- 2
- 3
next: That's cool!!
"
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x := docs.get(0)
	assert x is YamlMapValue
	if x is YamlMapValue {
		assert x.obj.len == 2
		dump(x.obj['arr_indent'] ?)
	}
	assert (x.get('arr_indent') ? as YamlListValue).ar == [YamlValue(i64(1)), i64(2), i64(3)]
	assert x.get('next') ?.string() ? == "That's cool!!"
	// assert false
}
