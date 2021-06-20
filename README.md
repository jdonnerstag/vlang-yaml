# Native YAML support for [V-lang](https://vlang.io)

## Key Features

- Read and parse yaml files (or data blocks)
- Tokenize the YAML file and derive YAML events (tokens) 
- Convert YAML events to a JSON string (and leverage V's built-in JSON decoder to load the json)
- Load the YAML into a tree-like structure of YamlValue's
- Tag definitions and references are mostly supported. By default references get replaced with their definition.

## API

```v
	pub fn xyz() ?voidptr
```

## Architecture

TextScanner: split into string tokens
	-> Scanner: map into basic yaml token
		-> Tokenizer: derive proper yaml events
            -> JSON output: convert into JSON string
				-> print
				-> json.decode() V built-in: load into V struct's
			-> Reader: load into dynamic YamlValue structure
				-> Accessor: path-like access to tree-like YamlValue structure

## Examples

### yaml-to-json command line tool

A little utility that reads a yaml file and prints the converted json to the console 
