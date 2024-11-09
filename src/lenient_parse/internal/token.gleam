import parse_error.{
  type ParseError, InvalidDecimalPosition, InvalidDigitPosition,
  InvalidExponentSymbolPosition, InvalidSignPosition, InvalidUnderscorePosition,
  OutOfBaseRange, UnknownCharacter,
}

pub type Token {
  Sign(String, Bool)
  Digit(character: String, value: Int, base: Int)
  Underscore
  DecimalPoint
  ExponentSymbol(String)
  Whitespace(String)
  Unknown(String)
}

pub fn to_error(token: Token, index) -> ParseError {
  case token {
    Sign(sign, _) -> InvalidSignPosition(sign, index)
    Digit(character, value, base) if value >= base ->
      OutOfBaseRange(character, value, base, index)
    Digit(character, _, _) -> InvalidDigitPosition(character, index)
    Underscore -> InvalidUnderscorePosition(index)
    DecimalPoint -> InvalidDecimalPosition(index)
    ExponentSymbol(exponent_symbol) ->
      InvalidExponentSymbolPosition(exponent_symbol, index)
    Whitespace(whitespace) -> UnknownCharacter(whitespace, index)
    Unknown(character) -> UnknownCharacter(character, index)
  }
}
