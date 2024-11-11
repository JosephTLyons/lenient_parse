import parse_error.{
  type ParseError, InvalidDecimalPosition, InvalidDigitPosition,
  InvalidExponentSymbolPosition, InvalidSignPosition, InvalidUnderscorePosition,
  OutOfBaseRange, UnknownCharacter,
}

pub type Token {
  Sign(#(Int, Int), String, Bool)
  Digit(#(Int, Int), character: String, value: Int, base: Int)
  Underscore(#(Int, Int))
  DecimalPoint(#(Int, Int))
  ExponentSymbol(#(Int, Int), String)
  Whitespace(#(Int, Int), String)
  Unknown(#(Int, Int), String)
}

pub fn to_error(token: Token) -> ParseError {
  case token {
    Sign(#(start_index, _), sign, _) -> InvalidSignPosition(sign, start_index)
    Digit(#(start_index, _), character, value, base) if value >= base ->
      OutOfBaseRange(character, value, base, start_index)
    Digit(#(start_index, _), character, _, _) ->
      InvalidDigitPosition(character, start_index)
    Underscore(#(start_index, _)) -> InvalidUnderscorePosition(start_index)
    DecimalPoint(#(start_index, _)) -> InvalidDecimalPosition(start_index)
    ExponentSymbol(#(start_index, _), exponent_symbol) ->
      InvalidExponentSymbolPosition(exponent_symbol, start_index)
    Whitespace(#(start_index, _), whitespace) ->
      UnknownCharacter(whitespace, start_index)
    Unknown(#(start_index, _), character) ->
      UnknownCharacter(character, start_index)
  }
}
