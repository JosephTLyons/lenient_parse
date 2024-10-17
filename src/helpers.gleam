import gleam/string

@internal
pub fn into_printable_text(text: String) -> String {
  do_into_printable_text(text |> string.to_graphemes, "")
}

fn do_into_printable_text(characters: List(String), acc: String) -> String {
  case characters {
    [] -> acc
    [first, ..rest] -> {
      let printable = case first {
        "\t" -> "\\t"
        "\n" -> "\\n"
        "\r" -> "\\r"
        "\f" -> "\\f"
        _ -> first
      }
      do_into_printable_text(rest, acc <> printable)
    }
  }
}
