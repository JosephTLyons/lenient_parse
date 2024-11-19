import gleam/dict.{type Dict}
import gleam/string
import lenient_parse/internal/whitespace.{type WhitespaceData}

pub fn to_printable_text(text: String) -> String {
  do_to_printable_text(
    characters: text |> string.to_graphemes,
    whitespace_strings_dict: whitespace.character_dict(),
    acc: "",
  )
}

fn do_to_printable_text(
  characters characters: List(String),
  whitespace_strings_dict whitespace_strings_dict: Dict(String, WhitespaceData),
  acc acc: String,
) -> String {
  case characters {
    [] -> acc
    [first, ..rest] -> {
      let printable = case whitespace_strings_dict |> dict.get(first) {
        Ok(whitespace_data) -> whitespace_data.printable
        Error(_) -> first
      }

      do_to_printable_text(
        characters: rest,
        whitespace_strings_dict: whitespace_strings_dict,
        acc: acc <> printable,
      )
    }
  }
}
