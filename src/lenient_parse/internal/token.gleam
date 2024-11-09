import parse_error.{
  type ParseError, InvalidDecimalPosition, InvalidDigitPosition,
  InvalidExponentSymbolPosition, InvalidSignPosition, InvalidUnderscorePosition,
  OutOfBaseRange, UnknownCharacter,
}

pub type Token {
  Sign(String, Bool)
  Digit(character: String, value: Int, is_within_base_range: Bool)
  Underscore
  DecimalPoint
  ExponentSymbol(String)
  Whitespace(String)
  Unknown(String)
}

pub fn to_error(token: Token, index) -> ParseError {
  case token {
    Sign(sign, _) -> InvalidSignPosition(sign, index)
    Digit(character, _, True) -> InvalidDigitPosition(character, index)
    Digit(character, value, False) -> OutOfBaseRange(character, value, index)
    Underscore -> InvalidUnderscorePosition(index)
    DecimalPoint -> InvalidDecimalPosition(index)
    ExponentSymbol(exponent_symbol) ->
      InvalidExponentSymbolPosition(exponent_symbol, index)
    Whitespace(whitespace) -> UnknownCharacter(whitespace, index)
    Unknown(character) -> UnknownCharacter(character, index)
  }
}
