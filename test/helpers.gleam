import gleam/string

pub fn to_printable_text(text: String, python_output: Bool) -> String {
  do_to_printable_text(
    characters: text |> string.to_graphemes,
    python_output: python_output,
    acc: "",
  )
}

fn do_to_printable_text(
  characters characters: List(String),
  python_output python_output: Bool,
  acc acc: String,
) -> String {
  case characters {
    [] -> acc
    [first, ..rest] -> {
      let printable = case first {
        "\t" -> "\\t"
        "\n" -> "\\n"
        "\r" -> "\\r"
        // Python weirdly converts "\f" to "\x0c"
        "\f" if python_output -> "\\x0c"
        "\f" -> "\\f"
        "\r\n" -> "\\r\\n"
        _ -> first
      }
      do_to_printable_text(
        characters: rest,
        python_output: python_output,
        acc: acc <> printable,
      )
    }
  }
}
