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
	assert x is YamlListValue
	if x is YamlListValue {
		assert x.ar.len == 3
		// eprintln(x.ar)
		assert x.ar[0] == YamlValue('Mark McGwire')
		assert x.ar[1] == YamlValue('Sammy Sosa')
		assert x.ar[2] == YamlValue('Ken Griffey')
	}
}

fn test_z_ex_02() ? {
	content := os.read_file('$test_data_dir/z_ex_02.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x := docs.get(0)
	assert x is YamlMapValue
	if x is YamlMapValue {
		assert x.obj.len == 3
		// eprintln(x.obj)
		assert x.obj['hr'] ? == YamlValue(i64(65))
		assert x.obj['avg'] ? == YamlValue(f64(0.278))
		assert x.obj['rbi'] ? == YamlValue(i64(147))
	}
}

fn test_z_ex_03() ? {
	content := os.read_file('$test_data_dir/z_ex_03.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 3
		x2 := x1.obj['american'] ?
		assert x2 is YamlListValue
		if x2 is YamlListValue {
			assert x2.ar.len == 3
			assert x2.ar[0] == YamlValue('Boston Red Sox')
			assert x2.ar[1] == YamlValue('Detroit Tigers')
			assert x2.ar[2] == YamlValue('New York Yankees')
		}
		x3 := x1.obj['national'] ?
		assert x3 is YamlListValue
		if x3 is YamlListValue {
			assert x3.ar.len == 3
			assert x3.ar[0] == YamlValue('New York Mets')
			assert x3.ar[1] == YamlValue('Chicago Cubs')
			assert x3.ar[2] == YamlValue('Atlanta Braves')
		}
		x4 := x1.obj["array"]?
		assert x4 is YamlListValue
		if x4 is YamlListValue {
			assert x4.ar.len == 3
			assert x4.ar[0] == YamlValue(i64(1))
			assert x4.ar[1] == YamlValue(i64(2))
			assert x4.ar[2] == YamlValue(i64(3))
		}
	}
}

fn test_z_ex_04() ? {
	content := os.read_file('$test_data_dir/z_ex_04.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlListValue
	if x1 is YamlListValue {
		assert x1.ar.len == 2
		x2 := x1.ar[0]
		assert x2 is YamlMapValue
		if x2 is YamlMapValue {
			assert x2.obj.len == 3
			assert x2.obj['name'] ? == YamlValue('Mark McGwire')
			assert x2.obj['hr'] ? == YamlValue(i64(65))
			assert x2.obj['avg'] ? == YamlValue(f64(0.278))
		}
		x3 := x1.ar[1]
		assert x3 is YamlMapValue
		if x3 is YamlMapValue {
			assert x3.obj.len == 3
			assert x3.obj['name'] ? == YamlValue('Sammy Sosa')
			assert x3.obj['hr'] ? == YamlValue(i64(63))
			assert x3.obj['avg'] ? == YamlValue(f64(0.288))
		}
	}
}

fn test_z_ex_05() ? {
	content := os.read_file('$test_data_dir/z_ex_05.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlListValue
	if x1 is YamlListValue {
		assert x1.ar.len == 3
		x2 := x1.ar[0]
		assert x2 is YamlListValue
		if x2 is YamlListValue {
			assert x2.ar.len == 3
			assert x2.ar == [YamlValue('name'), 'hr', 'avg']
		}
		x3 := x1.ar[1]
		assert x3 is YamlListValue
		if x3 is YamlListValue {
			assert x3.ar.len == 3
			assert x3.ar == [YamlValue('Mark McGwire'), i64(65), f64(0.278)]
		}
		x4 := x1.ar[2]
		assert x4 is YamlListValue
		if x4 is YamlListValue {
			assert x4.ar.len == 3
			assert x4.ar == [YamlValue('Sammy Sosa'), i64(63), f64(0.288)]
		}
	}
}

fn test_z_ex_06() ? {
	content := os.read_file('$test_data_dir/z_ex_06.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 2
		x2 := x1.obj['Mark McGwire'] ?
		assert x2 is YamlMapValue
		if x2 is YamlMapValue {
			assert x2.obj.len == 2
			assert x2.obj['hr'] ? == YamlValue(i64(65))
			assert x2.obj['avg'] ? == YamlValue(f64(0.278))
		}
		x3 := x1.obj['Sammy Sosa'] ?
		assert x3 is YamlMapValue
		if x3 is YamlMapValue {
			assert x3.obj.len == 2
			assert x3.obj['hr'] ? == YamlValue(i64(63))
			assert x3.obj['avg'] ? == YamlValue(f64(0.288))
		}
	}
}

fn test_z_ex_07() ? {
	content := os.read_file('$test_data_dir/z_ex_07.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 2
	x1 := docs.get(0)
	assert x1 is YamlListValue
	if x1 is YamlListValue {
		assert x1.ar.len == 3
		assert x1.ar[0] == YamlValue('Mark McGwire')
		assert x1.ar[1] == YamlValue('Sammy Sosa')
		assert x1.ar[2] == YamlValue('Ken Griffey')
	}
	x2 := docs.get(1)
	assert x2 is YamlListValue
	if x2 is YamlListValue {
		assert x2.ar.len == 2
		assert x2.ar[0] == YamlValue('Chicago Cubs')
		assert x2.ar[1] == YamlValue('St Louis Cardinals')
	}
}

fn test_z_ex_08() ? {
	content := os.read_file('$test_data_dir/z_ex_08.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 2
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 3
		assert x1.obj['time'] ? == YamlValue('20:03:20')
		assert x1.obj['player'] ? == YamlValue('Sammy Sosa')
		assert x1.obj['action'] ? == YamlValue('strike (miss)')
	}
	x2 := docs.get(1)
	assert x2 is YamlMapValue
	if x2 is YamlMapValue {
		assert x2.obj.len == 3
		assert x2.obj['time'] ? == YamlValue('20:03:47')
		assert x2.obj['player'] ? == YamlValue('Sammy Sosa')
		assert x2.obj['action'] ? == YamlValue('grand slam')
	}
}

fn test_z_ex_09() ? {
	content := os.read_file('$test_data_dir/z_ex_09.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 2
		x2 := x1.obj['hr'] ?
		assert x2 is YamlListValue
		if x2 is YamlListValue {
			assert x2.ar.len == 2
			assert x2.ar[0] == YamlValue('Mark McGwire')
			assert x2.ar[1] == YamlValue('Sammy Sosa')
		}
		x3 := x1.obj['rbi'] ?
		assert x3 is YamlListValue
		if x3 is YamlListValue {
			assert x3.ar.len == 2
			assert x3.ar[0] == YamlValue('Sammy Sosa')
			assert x3.ar[1] == YamlValue('Ken Griffey')
		}
	}
}

fn test_z_ex_10_in_tokenizer() ? {
	content := os.read_file('$test_data_dir/z_ex_10.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_tokenizer, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 2
		x2 := x1.obj['hr'] ?
		assert x2 is YamlListValue
		if x2 is YamlListValue {
			assert x2.ar.len == 2
			assert x2.ar[0] == YamlValue('Mark McGwire')
			assert x2.ar[1] == YamlValue('Sammy Sosa')
		}
		x3 := x1.obj['rbi'] ?
		assert x3 is YamlListValue
		if x3 is YamlListValue {
			assert x3.ar.len == 2
			assert x3.ar[0] == YamlValue('Sammy Sosa')
			assert x3.ar[1] == YamlValue('Ken Griffey')
		}
	}

	// Since the tags are already replaced in the tokenizer, they are no longer
	// visible to the reader.
	assert docs.tags.len == 0
}

fn test_z_ex_10() ? {
	content := os.read_file('$test_data_dir/z_ex_10.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 2
		x2 := x1.obj['hr'] ?
		assert x2 is YamlListValue
		if x2 is YamlListValue {
			assert x2.ar.len == 2
			assert x2.ar[0] == YamlValue('Mark McGwire')
			assert x2.ar[1] == YamlValue('Sammy Sosa')
		}
		x3 := x1.obj['rbi'] ?
		assert x3 is YamlListValue
		if x3 is YamlListValue {
			assert x3.ar.len == 2
			assert x3.ar[0] == YamlValue('Sammy Sosa')
			assert x3.ar[1] == YamlValue('Ken Griffey')
		}
	}

	assert docs.tags.len == 1
	assert 'SS' in docs.tags
	assert docs.tags['SS'] ? == YamlValue('Sammy Sosa')
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
	assert x1 is YamlListValue
	if x1 is YamlListValue {
		assert x1.ar.len == 3
		x2 := x1.ar[0]
		assert x2 is YamlMapValue
		if x2 is YamlMapValue {
			assert x2.obj.len == 2
			assert x2.obj['item'] ? == YamlValue('Super Hoop')
			assert x2.obj['quantity'] ? == YamlValue(i64(1))
		}
		x3 := x1.ar[1]
		assert x3 is YamlMapValue
		if x3 is YamlMapValue {
			assert x3.obj.len == 2
			assert x3.obj['item'] ? == YamlValue('Basketball')
			assert x3.obj['quantity'] ? == YamlValue(i64(4))
		}
		x4 := x1.ar[2]
		assert x4 is YamlMapValue
		if x4 is YamlMapValue {
			assert x4.obj.len == 2
			assert x4.obj['item'] ? == YamlValue('Big Shoes')
			assert x4.obj['quantity'] ? == YamlValue(i64(1))
		}
	}
}

fn test_z_ex_13() ? {
	content := os.read_file('$test_data_dir/z_ex_13.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is string
	if x1 is string {
		// According to the YAML spec, newline will always be "\n" irrespective of the OS
		assert x1 == '\\//||\\/||\n// ||  ||__'
	}
}

fn test_z_ex_14() ? {
	content := os.read_file('$test_data_dir/z_ex_14.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is string
	if x1 is string {
		assert x1 == "Mark McGwire's year was crippled by a knee injury."
	}
}

fn test_z_ex_15() ? {
	content := os.read_file('$test_data_dir/z_ex_15.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is string
	if x1 is string {
		// According to the YAML spec, newline will always be "\n" irrespective of the OS
		assert x1 == 'Sammy Sosa completed another fine season with great stats.\n\n  63 Home Runs\n  0.288 Batting Average\n\nWhat a year!'
	}
}

fn test_z_ex_16() ? {
	content := os.read_file('$test_data_dir/z_ex_16.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 3
		assert x1.obj['name'] ? == YamlValue('Mark McGwire')

		// According to https://www.json2yaml.com/ the following 2 require a "\n" at the very end.
		// However, I don't understand the logic. It is totally inconsistent.
		assert x1.obj['accomplishment'] ? == YamlValue('Mark set a major league home run record in 1998.')
		assert x1.obj['stats'] ? == YamlValue('65 Home Runs\n0.278 Batting Average\n')
	}
}

fn test_z_ex_17() ? {
	content := os.read_file('$test_data_dir/z_ex_17.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 6
		assert x1.obj['unicode'] ? == YamlValue('Sosa did fine.☺')
		assert x1.obj['control'] ? == YamlValue('\b1998\t1999\t2000\n')
		assert x1.obj['hex esc'] ? == YamlValue('\r\n is \r\n')
		assert x1.obj['single'] ? == YamlValue('"Howdy!" he cried.')
		assert x1.obj['quoted'] ? == YamlValue(" # Not a 'comment'.")
		assert x1.obj['tie-fighter'] ? == YamlValue('|\\-*-/|')
	}
}

fn test_z_ex_18() ? {
	content := os.read_file('$test_data_dir/z_ex_18.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 7
		assert x1.obj['plain 1'] ? == YamlValue('This unquoted scalar spans many lines. It has three lines.')
		assert x1.obj['plain 2'] ? == YamlValue('This is also multi-line')
		assert x1.obj['plain 3'] ? == YamlValue('The second line is more indented')
		assert x1.obj['plain 4'] ? == YamlValue('The third line is more indented')
		assert x1.obj['plain 5'] ? == YamlValue('This is another example that should work')
		assert x1.obj['plain 6'] ? == YamlValue('The second line\nis more indented')

		assert x1.obj['quoted'] ? == YamlValue('So does this quoted scalar with.\n')
	}
}

fn test_z_ex_19() ? {
	content := os.read_file('$test_data_dir/z_ex_19.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 4
		assert x1.obj['canonical'] ? == YamlValue(i64(12345))
		assert x1.obj['decimal'] ? == YamlValue(i64(12345))
		assert x1.obj['octal'] ? == YamlValue(i64(12))
		assert x1.obj['hexadecimal'] ? == YamlValue(i64(12))
	}
}

fn test_z_ex_20() ? {
	content := os.read_file('$test_data_dir/z_ex_20.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 5
		assert x1.obj['canonical'] ? == YamlValue(f64(1.23015e+3))
		assert x1.obj['exponential'] ? == YamlValue(f64(12.3015e+02))
		assert x1.obj['fixed'] ? == YamlValue(f64(1230.15))
		assert x1.obj['negative infinity'] ? == YamlValue('-.inf')
		assert x1.obj['not a number'] ? == YamlValue('.NaN')
	}
}

fn test_z_ex_21() ? {
	content := os.read_file('$test_data_dir/z_ex_21.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 3
		assert x1.obj['null'] ? == YamlValue('')
		assert x1.obj['string'] ? == YamlValue('012345') // quoted string are never casted
		x2 := x1.obj['booleans'] ?
		assert x2 is YamlListValue
		if x2 is YamlListValue {
			assert x2.ar.len == 2
			assert x2.ar[0] == YamlValue(true)
			assert x2.ar[1] == YamlValue(false)
		}
	}
}

fn test_z_ex_22() ? {
	content := os.read_file('$test_data_dir/z_ex_22.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 4
		assert x1.obj['canonical'] ? == YamlValue('2001-12-15T02:59:43.1Z')
		assert x1.obj['iso8601'] ? == YamlValue('2001-12-14t21:59:43.10-05:00')
		assert x1.obj['spaced'] ? == YamlValue('2001-12-14 21:59:43.10 -5')
		assert x1.obj['date'] ? == YamlValue('2002-12-14')
	}
}

fn test_z_ex_23() ? {
	content := os.read_file('$test_data_dir/z_ex_23.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 3
		assert x1.obj['not-date'] ? == YamlValue('2002-04-28')
		assert x1.obj['picture'] ? == YamlValue('R0lGODlhDAAMAIQAAP//9/X\n17unp5WZmZgAAAOfn515eXv\nPz7Y6OjuDg4J+fn5OTk6enp\n56enmleECcgggoBADs=\n')
		assert x1.obj['application specific tag'] ? == YamlValue('The semantics of the tag\nabove may be different for\ndifferent documents.\n')
	}
}

fn test_z_ex_24() ? {
	content := os.read_file('$test_data_dir/z_ex_24.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlListValue
	if x1 is YamlListValue {
		assert x1.ar.len == 3
		x2 := x1.ar[0]
		assert x2 is YamlMapValue
		if x2 is YamlMapValue {
			assert x2.obj.len == 2
			x3 := x2.obj['center'] ?
			assert x3 is YamlMapValue
			if x3 is YamlMapValue {
				assert x3.obj.len == 2
				assert x3.obj['x'] ? == YamlValue(i64(73))
				assert x3.obj['y'] ? == YamlValue(i64(129))
			}
			assert x2.obj['radius'] ? == YamlValue(i64(7))
		}
		x4 := x1.ar[1]
		assert x4 is YamlMapValue
		if x4 is YamlMapValue {
			assert x4.obj.len == 2
			x4a := x4.obj['start'] ?
			assert x4a is YamlMapValue
			if x4a is YamlMapValue {
				assert x4a.obj.len == 2
				assert x4a.obj['x'] ? == YamlValue(i64(73))
				assert x4a.obj['y'] ? == YamlValue(i64(129))
			}

			x5 := x4.obj['finish'] ?
			assert x5 is YamlMapValue
			if x5 is YamlMapValue {
				assert x5.obj.len == 2
				assert x5.obj['x'] ? == YamlValue(i64(89))
				assert x5.obj['y'] ? == YamlValue(i64(102))
			}
		}
		x6 := x1.ar[2]
		assert x6 is YamlMapValue
		if x6 is YamlMapValue {
			assert x6.obj.len == 3
			x4a := x6.obj['start'] ?
			assert x4a is YamlMapValue
			if x4a is YamlMapValue {
				assert x4a.obj.len == 2
				assert x4a.obj['x'] ? == YamlValue(i64(73))
				assert x4a.obj['y'] ? == YamlValue(i64(129))
			}

			assert x6.obj['color'] ? == YamlValue(i64(0xFFEEBB))
			assert x6.obj['text'] ? == YamlValue('Pretty vector drawing.')
		}
	}
}

fn test_z_ex_25() ? {
	content := os.read_file('$test_data_dir/z_ex_25.yaml') ?
	if _ := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) {
		assert false
	}
	// '?' is not yet support
	/*
	docs := yaml_reader(fpath, replace_tags: ReplaceTagsEnum.in_reader, debug: debug)?
	assert docs.documents.len == 1
	x := docs.get(0)
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
	assert x1 is YamlListValue
	if x1 is YamlListValue {
		assert x1.ar.len == 3
		x2 := x1.ar[0]
		assert x2 is YamlMapValue
		if x2 is YamlMapValue {
			assert x2.obj.len == 1
			assert x2.obj['Mark McGwire'] ? == YamlValue(i64(65))
		}
		x3 := x1.ar[1]
		assert x3 is YamlMapValue
		if x3 is YamlMapValue {
			assert x3.obj.len == 1
			assert x3.obj['Sammy Sosa'] ? == YamlValue(i64(63))
		}
		x4 := x1.ar[2]
		assert x4 is YamlMapValue
		if x4 is YamlMapValue {
			assert x4.obj.len == 1
			assert x4.obj['Ken Griffy'] ? == YamlValue(i64(58))
		}
	}
}

fn test_z_ex_27() ? {
	content := os.read_file('$test_data_dir/z_ex_27.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 8
		assert x1.obj['invoice'] ? == YamlValue(i64(34843))
	}
}

fn test_nested_objects() ? {
	content := os.read_file('$test_data_dir/nested_objects.yaml') ?
	docs := yaml_reader(content, replace_tags: ReplaceTagsEnum.in_reader, debug: debug) ?
	assert docs.documents.len == 1
	x1 := docs.get(0)
	assert x1 is YamlMapValue
	if x1 is YamlMapValue {
		assert x1.obj.len == 3
		assert x1.obj['aaa'] ? == YamlValue('string')
		x2 := x1.obj['bbb'] ?
		assert x2 is YamlMapValue
		if x2 is YamlMapValue {
			assert x2.obj.len == 1
			assert x2.obj['111'] ? == YamlValue('1-1-1')
		}
		x3 := x1.obj['ccc'] ?
		assert x3 is YamlMapValue
		if x3 is YamlMapValue {
			assert x3.obj.len == 2
			assert x3.obj['222'] ? == YamlValue('')
			assert x3.obj['223'] ? == YamlValue('xxx')
		}
	}
}

//
