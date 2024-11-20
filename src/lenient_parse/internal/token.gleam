import lenient_parse/internal/whitespace.{type WhitespaceData}
import parse_error.{
  type ParseError, InvalidDecimalPosition, InvalidDigitPosition,
  InvalidExponentSymbolPosition, InvalidSignPosition, InvalidUnderscorePosition,
  OutOfBaseRange, UnknownCharacter,
}

pub type Token {
  Sign(#(Int, Int), String, Bool)
  Digit(#(Int, Int), character: String, value: Int)
  Underscore(#(Int, Int))
  DecimalPoint(#(Int, Int))
  ExponentSymbol(#(Int, Int), String)
  Whitespace(#(Int, Int), data: WhitespaceData)
  // TDDO: Store value
  Unknown(#(Int, Int), String)
}

pub fn to_error(token: Token, base: Int) -> ParseError {
  case token {
    Sign(#(start_index, _), sign, _) -> InvalidSignPosition(start_index, sign)
    Digit(#(start_index, _), character, value) if value >= base ->
      OutOfBaseRange(start_index, character, value, base)
    Digit(#(start_index, _), character, _) ->
      InvalidDigitPosition(start_index, character)
    Underscore(#(start_index, _)) -> InvalidUnderscorePosition(start_index)
    DecimalPoint(#(start_index, _)) -> InvalidDecimalPosition(start_index)
    ExponentSymbol(#(start_index, _), exponent_symbol) ->
      InvalidExponentSymbolPosition(start_index, exponent_symbol)
    Whitespace(#(start_index, _), data) ->
      UnknownCharacter(start_index, data.printable)
    Unknown(#(start_index, _), character) ->
      UnknownCharacter(start_index, character)
  }
}
