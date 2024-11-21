import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lenient_parse/internal/base_constants.{base_10}
import lenient_parse/internal/token.{
  type Token, DecimalPoint, Digit, ExponentSymbol, Sign, Underscore, Unknown,
  Whitespace,
}
import lenient_parse/internal/whitespace.{type WhitespaceData}

pub fn tokenize_float(text text: String) -> List(Token) {
  text
  |> string.to_graphemes
  |> do_tokenize_float(
    index: 0,
    whitespace_character_dict: whitespace.character_dict(),
    acc: [],
  )
}

fn do_tokenize_float(
  characters characters: List(String),
  index index: Int,
  whitespace_character_dict whitespace_character_dict: Dict(
    String,
    WhitespaceData,
  ),
  acc acc: List(Token),
) -> List(Token) {
  case characters {
    [] -> acc |> list.reverse
    [first, ..rest] -> {
      let token = case first {
        "." -> DecimalPoint(index)
        "e" | "E" -> ExponentSymbol(index, first)
        _ ->
          common_token(
            character: first,
            index: index,
            whitespace_character_dict: whitespace_character_dict,
            tokenize_character_as_digit: fn(digit_value) {
              digit_value < base_10
            },
          )
      }
      do_tokenize_float(
        characters: rest,
        index: index + 1,
        whitespace_character_dict: whitespace_character_dict,
        acc: [token, ..acc],
      )
    }
  }
}

pub fn tokenize_int(text text: String) -> List(Token) {
  text
  |> string.to_graphemes
  |> do_tokenize_int(
    index: 0,
    whitespace_character_dict: whitespace.character_dict(),
    acc: [],
  )
}

fn do_tokenize_int(
  characters characters: List(String),
  index index: Int,
  whitespace_character_dict whitespace_character_dict: Dict(
    String,
    WhitespaceData,
  ),
  acc acc: List(Token),
) -> List(Token) {
  case characters {
    [] -> acc |> list.reverse
    [first, ..rest] -> {
      let token =
        common_token(
          character: first,
          index: index,
          tokenize_character_as_digit: fn(_) { True },
          whitespace_character_dict: whitespace_character_dict,
        )

      do_tokenize_int(
        characters: rest,
        index: index + 1,
        whitespace_character_dict: whitespace_character_dict,
        acc: [token, ..acc],
      )
    }
  }
}

fn common_token(
  character character: String,
  index index: Int,
  tokenize_character_as_digit tokenize_character_as_digit: fn(Int) -> Bool,
  whitespace_character_dict whitespace_character_dict: Dict(
    String,
    WhitespaceData,
  ),
) -> Token {
  case character {
    "-" -> Sign(index, "-", False)
    "+" -> Sign(index, "+", True)
    "_" -> Underscore(index)
    _ -> {
      case whitespace_character_dict |> dict.get(character) {
        Ok(whitespace_data) -> Whitespace(index, data: whitespace_data)
        Error(_) -> {
          case character_to_value(character) {
            Some(value) ->
              case tokenize_character_as_digit(value) {
                True -> Digit(index, character, value)
                False -> Unknown(index, character)
              }
            None -> Unknown(index, character)
          }
        }
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
