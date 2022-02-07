module yaml

// YAML spec: https://yaml.org/spec/1.2/spec.html
// To test your YAML: https://www.json2yaml.com/
import os

const test_data_dir = os.dir(@FILE) + '/test_data'

const debug = 0

const (
	z27 = [
		Token{ column: 1, typ: TokenKind.document, val: '---' },
		Token{ column: 1, typ: TokenKind.tag_url, val: '<tag:clarkevans.com,2002:invoice>' },
		Token{ column: 1, typ: TokenKind.newline, val: '' },
		Token{ column: 1, typ: TokenKind.xstr, val: 'invoice' },
		Token{ column: 1, typ: TokenKind.colon, val: ':' },
		Token{ column: 1, typ: TokenKind.xstr, val: '34843' },
		Token{ column: 1, typ: TokenKind.newline, val: '' },
		Token{ column: 1, typ: TokenKind.xstr, val: 'date' },
		Token{ column: 1, typ: TokenKind.colon, val: ':' },
		Token{ column: 1, typ: TokenKind.xstr, val: '2001-01-23' },
		Token{ column: 1, typ: TokenKind.newline, val: '' },
		Token{ column: 1, typ: TokenKind.xstr, val: 'bill-to' },
		Token{ column: 1, typ: TokenKind.colon, val: ':' },
		Token{ column: 1, typ: TokenKind.tag_def, val: 'id001' },
		Token{ column: 1, typ: TokenKind.newline, val: '' },
		Token{ column: 5, typ: TokenKind.xstr, val: 'given' },
		Token{ column: 5, typ: TokenKind.colon, val: ':' },
		Token{ column: 5, typ: TokenKind.xstr, val: 'Chris' },
		Token{ column: 5, typ: TokenKind.newline, val: '' },
		Token{ column: 5, typ: TokenKind.xstr, val: 'family' },
		Token{ column: 5, typ: TokenKind.colon, val: ':' },
		Token{ column: 5, typ: TokenKind.xstr, val: 'Dumars' },
		Token{ column: 5, typ: TokenKind.newline, val: '' },
		Token{ column: 5, typ: TokenKind.xstr, val: 'address' },
		Token{ column: 5, typ: TokenKind.colon, val: ':' },
		Token{ column: 5, typ: TokenKind.newline, val: '' },
		Token{ column: 9, typ: TokenKind.xstr, val: 'lines' },
		Token{ column: 9, typ: TokenKind.colon, val: ':' },
		Token{ column: 9, typ: TokenKind.xstr, val: '458 Walkman Dr.\nSuite #292'},
		Token{ column: 9, typ: TokenKind.newline, val: '' },
		Token{ column: 9, typ: TokenKind.xstr, val: 'city' },
		Token{ column: 9, typ: TokenKind.colon, val: ':' },
		Token{ column: 9, typ: TokenKind.xstr, val: 'Royal Oak' },
		Token{ column: 9, typ: TokenKind.newline, val: '' },
		Token{ column: 9, typ: TokenKind.xstr, val: 'state' },
		Token{ column: 9, typ: TokenKind.colon, val: ':' },
		Token{ column: 9, typ: TokenKind.xstr, val: 'MI' },
		Token{ column: 9, typ: TokenKind.newline, val: '' },
		Token{ column: 9, typ: TokenKind.xstr, val: 'postal' },
		Token{ column: 9, typ: TokenKind.colon, val: ':' },
		Token{ column: 9, typ: TokenKind.xstr, val: '48046' },
		Token{ column: 9, typ: TokenKind.newline, val: '' },
		Token{ column: 1, typ: TokenKind.xstr, val: 'ship-to' },
		Token{ column: 1, typ: TokenKind.colon, val: ':' },
		Token{ column: 1, typ: TokenKind.tag_ref, val: 'id001' },
		Token{ column: 1, typ: TokenKind.newline, val: '' },
		Token{ column: 1, typ: TokenKind.xstr, val: 'product' },
		Token{ column: 1, typ: TokenKind.colon, val: ':' },
		Token{ column: 1, typ: TokenKind.newline, val: '' },
		Token{ column: 6, typ: TokenKind.hyphen, val: '-' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'sku' },
		Token{ column: 7, typ: TokenKind.colon, val: ':' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'BL394D' },
		Token{ column: 7, typ: TokenKind.newline, val: '' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'quantity' },
		Token{ column: 7, typ: TokenKind.colon, val: ':' },
		Token{ column: 7, typ: TokenKind.xstr, val: '4' },
		Token{ column: 7, typ: TokenKind.newline, val: '' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'description' },
		Token{ column: 7, typ: TokenKind.colon, val: ':' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'Basketball' },
		Token{ column: 7, typ: TokenKind.newline, val: '' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'price' },
		Token{ column: 7, typ: TokenKind.colon, val: ':' },
		Token{ column: 7, typ: TokenKind.xstr, val: '450.00' },
		Token{ column: 7, typ: TokenKind.newline, val: '' },
		Token{ column: 6, typ: TokenKind.hyphen, val: '-' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'sku' },
		Token{ column: 7, typ: TokenKind.colon, val: ':' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'BL4438H' },
		Token{ column: 7, typ: TokenKind.newline, val: '' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'quantity' },
		Token{ column: 7, typ: TokenKind.colon, val: ':' },
		Token{ column: 7, typ: TokenKind.xstr, val: '1' },
		Token{ column: 7, typ: TokenKind.newline, val: '' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'description' },
		Token{ column: 7, typ: TokenKind.colon, val: ':' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'Super Hoop' },
		Token{ column: 7, typ: TokenKind.newline, val: '' },
		Token{ column: 7, typ: TokenKind.xstr, val: 'price' },
		Token{ column: 7, typ: TokenKind.colon, val: ':' },
		Token{ column: 7, typ: TokenKind.xstr, val: '2392.00' },
		Token{ column: 7, typ: TokenKind.newline, val: '' },
		Token{ column: 1, typ: TokenKind.xstr, val: 'tax' },
		Token{ column: 1, typ: TokenKind.colon, val: ':' },
		Token{ column: 1, typ: TokenKind.xstr, val: '251.42' },
		Token{ column: 1, typ: TokenKind.newline, val: '' },
		Token{ column: 1, typ: TokenKind.xstr, val: 'total' },
		Token{ column: 1, typ: TokenKind.colon, val: ':' },
		Token{ column: 1, typ: TokenKind.xstr, val: '4443.52' },
		Token{ column: 1, typ: TokenKind.newline, val: '' },
		Token{ column: 1, typ: TokenKind.xstr, val: 'comments' },
		Token{ column: 1, typ: TokenKind.colon, val: ':' },
		Token{ column: 1, typ: TokenKind.newline, val: '' },
		Token{ column: 5, typ: TokenKind.xstr, val: 'Late afternoon is best. Backup contact is Nancy Billsmer @ 338-4338.' },
	]
)

fn test_z_ex_27() ? {
	content := os.read_file('$test_data_dir/z_ex_27.yaml') ?
	scanner := yaml_scanner(content, debug) ?

	for i, tok in scanner.tokens {
		assert tok.typ == z27[i].typ
		assert tok.column == z27[i].column
		assert tok.val == z27[i].val
	}
}
