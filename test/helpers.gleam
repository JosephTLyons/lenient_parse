import gleam/dict.{type Dict}
import gleam/string
import lenient_parse/internal/whitespace.{type WhitespaceData}

pub fn to_printable_text(text: String) -> String {
  do_to_printable_text(
    characters: text |> string.to_graphemes,
    whitespace_character_dict: whitespace.character_dict(),
    acc: "",
  )
}

fn do_to_printable_text(
  characters characters: List(String),
  whitespace_character_dict whitespace_character_dict: Dict(
    String,
    WhitespaceData,
  ),
  acc acc: String,
) -> String {
  case characters {
    [] -> acc
    [first, ..rest] -> {
      let printable = case whitespace_character_dict |> dict.get(first) {
        Ok(whitespace_data) -> whitespace_data.printable
        Error(_) -> first
      }

      do_to_printable_text(
        characters: rest,
        whitespace_character_dict: whitespace_character_dict,
        acc: acc <> printable,
      )
    }
  }
}
