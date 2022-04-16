module text_scanner

pub enum Encodings {
	utf_32be // = "UTF-32BE"
	utf_32le // = "UTF-32LE"
	utf_16be // = "UTF-16BE"
	utf_16le // = "UTF-16LE"
	utf_8 // = "UTF-8"
}

pub fn detect_bom(str string) ?Encodings {
	if str.starts_with([u8(0x00), 0x00, 0xfe, 0xff].bytestr()) {
		return .utf_32be
	} else if str.starts_with([u8(0x00), 0x00, 0x00].bytestr()) {
		return .utf_32be
	} else if str.starts_with([u8(0xff), 0xfe, 0x00, 0x00].bytestr()) {
		return .utf_32le
	} else if str[1..].starts_with([u8(0x00), 0x00, 0x00].bytestr()) {
		return .utf_32le
	} else if str.starts_with([u8(0xfe), 0xff].bytestr()) {
		return .utf_16be
	} else if str.starts_with([u8(0x00)].bytestr()) {
		return .utf_16be
	} else if str.starts_with([u8(0xff), 0xfe].bytestr()) {
		return .utf_16le
	} else if str[1..].starts_with([u8(0x00)].bytestr()) {
		return .utf_16le
	} else if str.starts_with([u8(0xef), 0xbb, 0xbf].bytestr()) {
		return .utf_8
	} else {
		return none
	}
}
