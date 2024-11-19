import gleam/dict.{type Dict}
import gleam/list

pub type WhitespaceData {
  WhitespaceData(
    character: String,
    printable: String,
    codepoint_values: List(Int),
  )
}

pub fn character_dict() -> Dict(String, WhitespaceData) {
  [
    horizontal_tab,
    line_feed,
    vertical_tab,
    form_feed,
    carriage_return,
    space,
    next_line,
    no_break_space,
    ogham_space_mark,
    en_quad,
    em_quad,
    en_space,
    em_space,
    three_per_em_space,
    four_per_em_space,
    six_per_em_space,
    figure_space,
    punctuation_space,
    thin_space,
    hair_space,
    line_separator,
    paragraph_separator,
    narrow_no_break_space,
    medium_mathematical_space,
    ideographic_space,
    windows_newline,
  ]
  |> list.map(fn(whitespace_data) {
    #(whitespace_data.character, whitespace_data)
  })
  |> dict.from_list
}

// https://en.wikipedia.org/wiki/List_of_Unicode_characters

pub const horizontal_tab = WhitespaceData(
  character: "\u{0009}",
  printable: "\\t",
  codepoint_values: [0x9],
)

pub const line_feed = WhitespaceData(
  character: "\u{000A}",
  printable: "\\n",
  codepoint_values: [0xA],
)

pub const vertical_tab = WhitespaceData(
  character: "\u{000B}",
  printable: "\\x0b",
  codepoint_values: [0xB],
)

pub const form_feed = WhitespaceData(
  character: "\u{000C}",
  printable: "\\x0c",
  codepoint_values: [0xC],
)

pub const carriage_return = WhitespaceData(
  character: "\u{000D}",
  printable: "\\r",
  codepoint_values: [0xD],
)

pub const space = WhitespaceData(
  character: "\u{0020}",
  printable: " ",
  codepoint_values: [0x20],
)

pub const next_line = WhitespaceData(
  character: "\u{0085}",
  printable: "\\x85",
  codepoint_values: [0x85],
)

pub const no_break_space = WhitespaceData(
  character: "\u{00A0}",
  printable: "\\xa0",
  codepoint_values: [0xA0],
)

pub const ogham_space_mark = WhitespaceData(
  character: "\u{1680}",
  printable: "\\u1680",
  codepoint_values: [0x1680],
)

pub const en_quad = WhitespaceData(
  character: "\u{2000}",
  printable: "\\u2000",
  codepoint_values: [0x2000],
)

pub const em_quad = WhitespaceData(
  character: "\u{2001}",
  printable: "\\u2001",
  codepoint_values: [0x2001],
)

pub const en_space = WhitespaceData(
  character: "\u{2002}",
  printable: "\\u2002",
  codepoint_values: [0x2002],
)

pub const em_space = WhitespaceData(
  character: "\u{2003}",
  printable: "\\u2003",
  codepoint_values: [0x2003],
)

pub const three_per_em_space = WhitespaceData(
  character: "\u{2004}",
  printable: "\\u2004",
  codepoint_values: [0x2004],
)

pub const four_per_em_space = WhitespaceData(
  character: "\u{2005}",
  printable: "\\u2005",
  codepoint_values: [0x2005],
)

pub const six_per_em_space = WhitespaceData(
  character: "\u{2006}",
  printable: "\\u2006",
  codepoint_values: [0x2006],
)

pub const figure_space = WhitespaceData(
  character: "\u{2007}",
  printable: "\\u2007",
  codepoint_values: [0x2007],
)

pub const punctuation_space = WhitespaceData(
  character: "\u{2008}",
  printable: "\\u2008",
  codepoint_values: [0x2008],
)

pub const thin_space = WhitespaceData(
  character: "\u{2009}",
  printable: "\\u2009",
  codepoint_values: [0x2009],
)

pub const hair_space = WhitespaceData(
  character: "\u{200A}",
  printable: "\\u200a",
  codepoint_values: [0x200A],
)

pub const line_separator = WhitespaceData(
  character: "\u{2028}",
  printable: "\\u2028",
  codepoint_values: [0x2028],
)

pub const paragraph_separator = WhitespaceData(
  character: "\u{2029}",
  printable: "\\u2029",
  codepoint_values: [0x2029],
)

pub const narrow_no_break_space = WhitespaceData(
  character: "\u{202F}",
  printable: "\\u202f",
  codepoint_values: [0x202F],
)

pub const medium_mathematical_space = WhitespaceData(
  character: "\u{205F}",
  printable: "\\u205f",
  codepoint_values: [0x205F],
)

pub const ideographic_space = WhitespaceData(
  character: "\u{3000}",
  printable: "\\u3000",
  codepoint_values: [0x3000],
)

// ---- Specialty characters

pub const windows_newline = WhitespaceData(
  character: "\u{000D}\u{000A}",
  printable: "\\r\\n",
  codepoint_values: [0x000D, 0x000A],
)
