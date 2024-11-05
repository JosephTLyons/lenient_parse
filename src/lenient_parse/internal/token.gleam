import gleam/int
import parse_error.{
  type ParseError, InvalidDecimalPosition, InvalidDigitPosition,
  InvalidExponentPosition, InvalidSignPosition, InvalidUnderscorePosition,
  UnknownCharacter,
}

pub type Token {
  Sign(String, Bool)
  Digit(Int)
  Underscore
  DecimalPoint
  Exponent(String)
  Whitespace(String)
  Unknown(String)
}

pub fn to_error(token: Token, index) -> ParseError {
  case token {
    Sign(sign, _) -> InvalidSignPosition(sign, index)
    Digit(digit) -> InvalidDigitPosition(digit |> int.to_string, index)
    Underscore -> InvalidUnderscorePosition(index)
    DecimalPoint -> InvalidDecimalPosition(index)
    Exponent(exponent) -> InvalidExponentPosition(exponent, index)
    Whitespace(whitespace) -> UnknownCharacter(whitespace, index)
    Unknown(character) -> UnknownCharacter(character, index)
  }
}
