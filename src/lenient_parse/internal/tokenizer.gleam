import gleam/list
import gleam/string

pub type Token {
  Sign(String)
  Digit(String)
  Underscore
  DecimalPoint
  Whitespace(String)
  Unknown(String)
}

pub fn tokenize_number_string(text: String) -> List(Token) {
  text |> string.to_graphemes |> do_tokenize_number_string([])
}

fn do_tokenize_number_string(
  characters: List(String),
  acc: List(Token),
) -> List(Token) {
  case characters {
    [] -> acc |> list.reverse
    [first, ..rest] -> {
      let token = case first {
        "-" | "+" -> Sign(first)
        "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ->
          Digit(first)
        "." -> DecimalPoint
        "_" -> Underscore
        " " | "\n" | "\t" | "\r" | "\f" -> Whitespace(first)
        _ -> Unknown(first)
      }

      do_tokenize_number_string(rest, [token, ..acc])
    }
  }
}

pub fn is_digit(token: Token) -> Bool {
  case token {
    Digit(_) -> True
    _ -> False
  }
}

// TODO: Better name
pub fn get_valid_character(token: Token) -> Result(String, String) {
  case token {
    DecimalPoint -> Ok(".")
    Underscore -> Ok("_")
    Digit(a) | Sign(a) -> Ok(a)
    Unknown(a) | Whitespace(a) -> Error(a)
  }
}
