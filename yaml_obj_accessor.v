module yaml

pub type PathType = int | string

pub fn (this YamlValue) get(path ...PathType) ?YamlValue {
	mut rtn := this

	for p in path {
		if p is int {
			if mut rtn is YamlListValue {
				if p < 0 || p >= rtn.ar.len {
					return error("Invalid index to access Yaml list element: '$p'")
				}
				rtn = rtn.ar[p]
			} else {
				return error("'int' path element can only be used with Yaml lists")
			}
		} else if p is string {
			if mut rtn is YamlMapValue {
				if p in rtn.obj {
					rtn = rtn.obj[p] ?
				} else {
					return error("Key not found in Yaml map element: '$p'")
				}
			} else {
				return error("'string' path element can only be used with Yaml maps")
			}
		}
	}

	return rtn
}

pub fn (this YamlValue) is_list() bool {
	return this is YamlListValue
}

pub fn (this YamlValue) is_map() bool {
	return this is YamlMapValue
}

pub fn (this YamlValue) is_value() bool {
	return match this {
		string { true }
		i64 { true }
		f64 { true }
		bool { true }
		else { false }
	}
}

pub fn (this YamlValue) len() int {
	if this is string {
		return this.len
	} else if this is YamlListValue {
		return this.ar.len
	} else if this is YamlMapValue {
		return this.obj.len
	} else {
		panic("Invalid YamlValue to determine 'len': $this")
	}
}

pub fn (this YamlValue) is_empty() bool {
	return this.len() == 0
}

pub fn (this YamlValue) string() ?string {
	match this {
		string {
			return this
		}
		i64 {
			return this.str()
		}
		f64 {
			return this.str()
		}
		bool {
			return this.str()
		}
		else {
			return error("Invalid YamlValue to return a 'string': $this")
		}
	}
}

pub fn (this YamlValue) get_str(path ...PathType) ?string {
	return this.get(...path) ?.string()
}

pub fn (this YamlValue) get_int(path ...PathType) ?int {
	return this.get(...path) ?.int()
}

pub fn (this YamlValue) get_float(path ...PathType) ?f64 {
	return this.get(...path) ?.f64()
}

pub fn (this YamlValue) get_bool(path ...PathType) ?bool {
	return this.get(...path) ?.bool()
}

pub fn (this YamlValue) i8() ?i8 {
	return i8(this.i64() ?)
}

pub fn (this YamlValue) i16() ?i16 {
	return i16(this.i64() ?)
}

pub fn (this YamlValue) int() ?int {
	return int(this.i64() ?)
}

pub fn (this YamlValue) i64() ?i64 {
	if this is i64 {
		return this
	}
	panic('Unable to determine i64 value: $this')
}

pub fn (this YamlValue) u8() ?u8 {
	return u8(this.i64() ?)
}

pub fn (this YamlValue) u16() ?u16 {
	return u16(this.i64() ?)
}

pub fn (this YamlValue) u32() ?u32 {
	return u32(this.i64() ?)
}

pub fn (this YamlValue) u64() ?u64 {
	return u64(this.i64() ?)
}

pub fn (this YamlValue) f32() ?f32 {
	return f32(this.f64() ?)
}

pub fn (this YamlValue) f64() ?f64 {
	if this is f64 {
		return this
	}
	panic('Unable to determine f64 value: $this')
}

// TODO Tests are missing??
pub fn (this YamlValue) bool() ?bool {
	if this is bool {
		return this
	}
	if this is i64 {
		return if this == 0 { false } else { true }
	}
	panic('Unable to determine f64 value: $this')
}

// get_date Return an integer with YYYYMMDD digits
// TODO To be implemented
// TODO How to make YamlValue extendable, so that USERS can extend it with their own converters?
pub fn (this YamlValue) get_date(fmt string) ?i64 {
	// TODO Does i64()? panic if not an int ?!?!?
	return this.string() ?.i64()
}

// get_time Return an integer with HHMMSS digits
// TODO To be implemented
// TODO How to make YamlValue extendable, so that USERS can extend it with their own converters?
pub fn (this YamlValue) get_time(fmt string) ?i64 {
	return this.string() ?.i64()
}

// get_millis Return milli seconds since 1970 (UNIX style)
// TODO To be implemented
// TODO How to make YamlValue extendable, so that USERS can extend it with their own converters?
pub fn (this YamlValue) get_millis(fmt string) ?i64 {
	return this.string() ?.i64()
}
