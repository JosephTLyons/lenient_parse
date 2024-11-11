import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lenient_parse/internal/base_constants.{
  base_0, base_10, base_16, base_2, base_8,
}
import lenient_parse/internal/token.{
  type Token, BasePrefix, DecimalPoint, Digit, ExponentSymbol, Sign, Underscore,
  Unknown, Whitespace,
}

pub fn tokenize_float(text text: String) -> List(Token) {
  text |> string.to_graphemes |> do_tokenize_float(index: 0, acc: [])
}

fn do_tokenize_float(
  characters characters: List(String),
  index index: Int,
  acc acc: List(Token),
) -> List(Token) {
  case characters {
    [] -> acc |> list.reverse
    [first, ..rest] -> {
      let token = case first {
        "." -> DecimalPoint(#(index, index + 1))
        "e" | "E" -> ExponentSymbol(#(index, index + 1), first)
        _ ->
          common_token(
            character: first,
            index: index,
            tokenize_character_as_digit: fn(digit_value) {
              digit_value < base_10
            },
          )
      }
      do_tokenize_float(characters: rest, index: index + 1, acc: [token, ..acc])
    }
  }
}

pub fn tokenize_int(text text: String, base base: Int) -> List(Token) {
  text
  |> string.to_graphemes
  |> do_tokenize_int(base: base, index: 0, base_prefix_found: False, acc: [])
}

fn do_tokenize_int(
  characters characters: List(String),
  base base: Int,
  index index: Int,
  base_prefix_found base_prefix_found: Bool,
  acc acc: List(Token),
) -> List(Token) {
  case characters {
    [] -> acc |> list.reverse
    [first, ..rest] -> {
      let lookahead = rest |> list.first

      let #(index, token, rest, base_prefix_found) = case
        base_prefix_found,
        first,
        lookahead
      {
        False, "0", Ok(specifier)
          if { base == base_0 || base == base_2 }
          && { specifier == "b" || specifier == "B" }
        -> create_base_prefix(index, specifier, base_2, rest)
        False, "0", Ok(specifier)
          if { base == base_0 || base == base_8 }
          && { specifier == "o" || specifier == "O" }
        -> create_base_prefix(index, specifier, base_8, rest)
        False, "0", Ok(specifier)
          if { base == base_0 || base == base_16 }
          && { specifier == "x" || specifier == "X" }
        -> create_base_prefix(index, specifier, base_16, rest)
        _, _, _ -> {
          let token =
            common_token(
              character: first,
              index: index,
              tokenize_character_as_digit: fn(_) { True },
            )

          #(index + 1, token, rest, base_prefix_found)
        }
      }

      do_tokenize_int(
        characters: rest,
        base: base,
        index: index,
        base_prefix_found: base_prefix_found,
        acc: [token, ..acc],
      )
    }
  }
}

fn create_base_prefix(
  index: Int,
  specifier: String,
  base: Int,
  rest: List(String),
) -> #(Int, Token, List(String), Bool) {
  let token = BasePrefix(#(index, index + 2), "0" <> specifier, base)
  let new_rest = case rest {
    [] -> []
    [_, ..rest] -> rest
  }
  #(index + 2, token, new_rest, True)
}

fn common_token(
  character character: String,
  index index: Int,
  tokenize_character_as_digit tokenize_character_as_digit: fn(Int) -> Bool,
) -> Token {
  case character {
    "-" -> Sign(#(index, index + 1), "-", False)
    "+" -> Sign(#(index, index + 1), "+", True)
    "_" -> Underscore(#(index, index + 1))
    " " | "\n" | "\t" | "\r" | "\f" | "\r\n" ->
      Whitespace(#(index, index + 1), character)
    _ -> {
      case character_to_value(character) {
        Some(value) ->
          case tokenize_character_as_digit(value) {
            True -> Digit(#(index, index + 1), character, value)
            False -> Unknown(#(index, index + 1), character)
          }
        None -> Unknown(#(index, index + 1), character)
      }
    }
  }
}

fn character_to_value(character: String) -> Option(Int) {
  case character {
    "0" -> Some(0)
    "1" -> Some(1)
    "2" -> Some(2)
    "3" -> Some(3)
    "4" -> Some(4)
    "5" -> Some(5)
    "6" -> Some(6)
    "7" -> Some(7)
    "8" -> Some(8)
    "9" -> Some(9)
    "a" | "A" -> Some(10)
    "b" | "B" -> Some(11)
    "c" | "C" -> Some(12)
    "d" | "D" -> Some(13)
    "e" | "E" -> Some(14)
    "f" | "F" -> Some(15)
    "g" | "G" -> Some(16)
    "h" | "H" -> Some(17)
    "i" | "I" -> Some(18)
    "j" | "J" -> Some(19)
    "k" | "K" -> Some(20)
    "l" | "L" -> Some(21)
    "m" | "M" -> Some(22)
    "n" | "N" -> Some(23)
    "o" | "O" -> Some(24)
    "p" | "P" -> Some(25)
    "q" | "Q" -> Some(26)
    "r" | "R" -> Some(27)
    "s" | "S" -> Some(28)
    "t" | "T" -> Some(29)
    "u" | "U" -> Some(30)
    "v" | "V" -> Some(31)
    "w" | "W" -> Some(32)
    "x" | "X" -> Some(33)
    "y" | "Y" -> Some(34)
    "z" | "Z" -> Some(35)
    _ -> None
  }
}
