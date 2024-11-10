import gleam/string

pub fn to_printable_text(text: String) -> String {
  do_to_printable_text(text |> string.to_graphemes, "")
}

fn do_to_printable_text(characters: List(String), acc: String) -> String {
  case characters {
    [] -> acc
    [first, ..rest] -> {
      let printable = case first {
        "\t" -> "\\t"
        "\n" -> "\\n"
        "\r" -> "\\r"
        "\f" -> "\\f"
        "\r\n" -> "\\r\\n"
        _ -> first
      }
      do_to_printable_text(rest, acc <> printable)
    }
  }
}
