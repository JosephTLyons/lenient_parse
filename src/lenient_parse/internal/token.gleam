import lenient_parse/internal/whitespace.{type WhitespaceData}
import parse_error.{
  type ParseError, InvalidDecimalPosition, InvalidDigitPosition,
  InvalidExponentSymbolPosition, InvalidSignPosition, InvalidUnderscorePosition,
  OutOfBaseRange, UnknownCharacter,
}

pub type Token {
  Sign(Int, String, Bool)
  Digit(Int, character: String, value: Int)
  Underscore(Int)
  DecimalPoint(Int)
  ExponentSymbol(Int, String)
  Whitespace(Int, data: WhitespaceData)
  Unknown(Int, String)
}

pub fn to_error(token: Token, base: Int) -> ParseError {
  case token {
    Sign(index, sign, _) -> InvalidSignPosition(index, sign)
    Digit(index, character, value) if value >= base ->
      OutOfBaseRange(index, character, value, base)
    Digit(index, character, _) -> InvalidDigitPosition(index, character)
    Underscore(index) -> InvalidUnderscorePosition(index)
    DecimalPoint(index) -> InvalidDecimalPosition(index)
    ExponentSymbol(index, exponent_symbol) ->
      InvalidExponentSymbolPosition(index, exponent_symbol)
    Whitespace(index, data) -> UnknownCharacter(index, data.printable)
    Unknown(index, character) -> UnknownCharacter(index, character)
  }
}
