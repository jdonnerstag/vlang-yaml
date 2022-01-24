# Native YAML support for [V-lang](https://vlang.io)

I think this YAML parser covers many important aspects of the YAML spec, but certainly not everything. I've been using the [YAML spec](https://yaml.org/spec/1.2/spec.html) and [this online tool](https://www.json2yaml.com/) whenever I was in doubt.

This is an initial version. Please apply some caution and report issues back to me.

Since this is an initial version, it is not yet performance tested. I'm sure there is room for improvements.


## Key Features

- Read and parse yaml files (or data blocks); utf-8 only
- Tokenize the YAML file and derive YAML events (tokens) 
- Convert YAML events to a JSON string (and leverage V's built-in JSON decoder to load json)
- Load the YAML file into a tree-like structure of dynamic YamlValue's  (V is currently lacking the feature to map (YAML) values to struct variables. The respective JSON logic is build into the compiler. It is not possible for
users to define their own [attributes] right now)
- Value types, such as string, int, float and bool are auto-detected and carried forward
- Tag definitions and references are mostly supported. By default references get replaced with their definition.
- Multiple YAML documents within a file is supported (mostly)
- un-escape and interpolate strings, hex numbers, etc.


## Architecture

```
TextScanner: split text into string tokens (generic)
    -> Scanner: map into basic yaml-like tokens
        -> Tokenizer: derive proper yaml tokens (events)
            -> JSON output: convert into JSON string
                -> print
                -> json.decode() V built-in: load into V struct's
            -> Reader: load into dynamic YamlValue structure
                -> Accessor: path-like access to tree-like YamlValue structure
```

**TextScanner**: A generic module, not YAML specific, with re-useable functions to detect newline, handle line count, skip whitespace, move to end-of-line, set a marker at a certain position and retrieve the text between the marker and the current postion, read quoted strings, etc.

**Scanner**: Leverage TextScanner to parse the YAML file into basic YAML tokens, properly determine indentation (very important in YAML), the different multi-line text variants, identify special chars such as `-:{}[],!---...`, etc. The token generated consist of a type, the indentiation level and the associated string.

**Tokenizer**: What we really want are YAML events such as start-list, close, start-object, key, value, end-of-document, tag-definition, tag-reference, etc.. YAML files very human readable, but not very computer friendly. The Tokenizer creates a nice stream of YAML events that can easily be leveraged for different purposes, such as generate JSON, or create dynamic YamlValue's.

**JSON output**: Convert the stream of YAML events into a JSON string. This json string can be used by V's build-in decoder to load the YAML data into V struct's. 

**YAML Reader**: User defined [attributes] are not yet supported. Hence the YAML data can only be loaded into V struct's via JSON's built-in JSON decoder. Reader creates a completely dynamic tree-like structure, based on YamlValue's, reflecting lists, objects, key and values, including value types (string, int, float, bool). This is a little bit like in dynamic languages, such as Python.

**Accessor**: Traversing the tree of YamlValue's that make up a yaml file, is not especially pleasant. Accessor provides getter functions, so that by means of a 'path' the value can be accessed. Additionally type converters are provided, to return i8, i16, int, i64, f32, f64, bool etc. values.

## API

```v
	import yaml
	
	content := os.read_file("myfile.yaml")?
	scanner := yaml.yaml_scanner(content, debug)?
	for i, tok in scanner.tokens { .. }

	tokenizer := yaml.yaml_tokenizer(content, replace_tags: true, debug: debug)?
	for i, tok in tokenizer.tokens { .. }

	json_data := yaml.yaml_to_json(content, replace_tags: true, debug: debug)?
	println(json_data)

	docs := yaml.yaml_reader(content)?
	x := docs.get(0)	// Most files have only 1 (implict) document
	assert x.get("american", 0)?.string()? == "Boston Red Sox"

	// with additional options
	docs := yaml.yaml_reader(content, replace_tags: yaml.ReplaceTagsEnum.in_reader, debug: debug)?

	// Path-like getter for YAML values
	assert x1.get(0, "center", "x")?.int()? == 73
```

## Examples

There is a reasonable amount of test cases for each major component. Probably a good starting point for anybody who want to dig a bit deeper.

### Yaml-to-json command line tool

In the `./examples` folder is a little command line utility that reads a yaml file and prints json to the console 
