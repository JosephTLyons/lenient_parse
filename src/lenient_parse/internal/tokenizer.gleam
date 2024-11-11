import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lenient_parse/internal/token.{
  type Token, DecimalPoint, Digit, ExponentSymbol, InferredBase, Sign,
  Underscore, Unknown, Whitespace,
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
      let base = 10
      let token = case first {
        "." -> DecimalPoint(#(index, index + 1))
        "e" | "E" -> ExponentSymbol(#(index, index + 1), first)
        _ ->
          common_token(
            character: first,
            index: index,
            tokenize_character_as_digit: fn(digit_value) { digit_value < base },
            base: base,
          )
      }
      do_tokenize_float(characters: rest, index: index + 1, acc: [token, ..acc])
    }
  }
}

pub fn tokenize_int(text text: String, base base: Int) -> List(Token) {
  text
  |> string.to_graphemes
  |> do_tokenize_int(base: base, index: 0, inferred_base_found: False, acc: [])
}

// TODO - clean up this logic, super WET
fn do_tokenize_int(
  characters characters: List(String),
  base base: Int,
  index index: Int,
  inferred_base_found inferred_base_found: Bool,
  acc acc: List(Token),
) -> List(Token) {
  case characters {
    [] -> acc |> list.reverse
    [first, ..rest] -> {
      let lookahead = rest |> list.first

      case inferred_base_found, base, first, lookahead {
        False, 0, "0", Ok(a) if a == "b" || a == "B" -> {
          let base = 2
          let token = InferredBase(#(index, index + 2), "0" <> a, base)
          let rest = case rest {
            [] -> []
            [_, ..rest] -> rest
          }

          do_tokenize_int(
            characters: rest,
            base: base,
            index: index + 2,
            inferred_base_found: True,
            acc: [token, ..acc],
          )
        }
        False, 0, "0", Ok(a) if a == "o" || a == "O" -> {
          let base = 8
          let token = InferredBase(#(index, index + 2), "0" <> a, base)
          let rest = case rest {
            [] -> []
            [_, ..rest] -> rest
          }

          do_tokenize_int(
            characters: rest,
            base: base,
            index: index + 2,
            inferred_base_found: True,
            acc: [token, ..acc],
          )
        }
        False, 0, "0", Ok(a) if a == "x" || a == "X" -> {
          let base = 16
          let token = InferredBase(#(index, index + 2), "0" <> a, base)
          let rest = case rest {
            [] -> []
            [_, ..rest] -> rest
          }

          do_tokenize_int(
            characters: rest,
            base: base,
            index: index + 2,
            inferred_base_found: True,
            acc: [token, ..acc],
          )
        }

        // _, 0, _, _ -> {
        //   let token =
        //     common_token(
        //       character: first,
        //       index: index,
        //       tokenize_character_as_digit: fn(_) { True },
        //       base: base,
        //     )
        //   let base = 10
        //   case token {
        //     Digit(_, _, _, _) -> {
        //       let base = 10
        //       do_tokenize_int(
        //         characters: rest,
        //         base: base,
        //         index: index + 1,
        //         inferred_base_found: True,
        //         acc: [token, ..acc],
        //       )
        //     }
        //     token -> {
        //       do_tokenize_int(
        //         characters: rest,
        //         base: base,
        //         index: index + 1,
        //         inferred_base_found: True,
        //         acc: [token, ..acc],
        //       )
        //     }
        //   }
        // }
        _, _, _, _ -> {
          let token =
            common_token(
              character: first,
              index: index,
              tokenize_character_as_digit: fn(_) { True },
              base: base,
            )

          do_tokenize_int(
            characters: rest,
            base: base,
            index: index + 1,
            inferred_base_found: inferred_base_found,
            acc: [token, ..acc],
          )
        }
      }
    }
  }
}

fn common_token(
  character character: String,
  index index: Int,
  tokenize_character_as_digit tokenize_character_as_digit: fn(Int) -> Bool,
  base base: Int,
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
            True -> Digit(#(index, index + 1), character, value, base)
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
// TODO
// First, determine if we need to use block tokenization
// If so, then the parser only needs to check the first two characters of the digit strin
// If not, then the tokenizer needs to store the 2 characters in the InferredBase variant
