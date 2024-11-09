import gleam/int

pub type ParseError {
  /// Represents an error when the input string is empty.
  EmptyString

  /// Represents an error when the input string contains only whitespace
  /// characters.
  WhitespaceOnlyString

  /// Represents an error when an underscore is in an invalid position within
  /// the number string.
  ///
  /// - `index`: The position of the invalid underscore in the input string.
  InvalidUnderscorePosition(index: Int)

  /// Represents an error when a decimal point is in an invalid position within
  /// the number string.
  ///
  /// - `index`: The position of the invalid decimal point in the input string.
  InvalidDecimalPosition(index: Int)

  /// Represents an error when a sign (+ or -) is in an invalid position within
  /// the number string.
  ///
  /// - `character`: The sign character that caused the error as a `String`.
  /// - `index`: The position of the invalid sign in the input string.
  InvalidSignPosition(character: String, index: Int)

  /// Represents an error when a digit is in an invalid position within the
  /// number string.
  ///
  /// - `character`: The digit character that caused the error as a `String`.
  /// - `index`: The position of the invalid digit in the input string.
  InvalidDigitPosition(character: String, index: Int)

  /// Represents an error when a digit is out of the valid range for the specified base.
  ///
  /// - `character`: The string representation of the out-of-range digit.
  /// - `value`: The integer value of the out-of-range digit.
  /// - `index`: The position of the out-of-range digit in the input string.
  OutOfBaseRange(character: String, value: Int, index: Int)

  /// Represents an error when an exponent symbol (e or E) is in an invalid
  /// position within the number string.
  ///
  /// - `character`: The exponent symbol that caused the error as a `String`.
  /// - `index`: The position of the invalid exponent symbol in the input string.
  InvalidExponentSymbolPosition(character: String, index: Int)

  /// Represents an error when an invalid character is encountered during
  /// parsing.
  ///
  /// - `character`: The invalid character as a `String`.
  /// - `index`: The position of the invalid character in the input string.
  UnknownCharacter(character: String, index: Int)

  /// Represents an error when the base provided for parsing is invalid.
  ///
  /// - `base`: The invalid base as an `Int`. The base must be between 2 and 36 inclusive, or 0.
  InvalidBaseValue(base: Int)
}

@internal
pub fn to_string(error: ParseError) -> String {
  case error {
    EmptyString -> "empty string"
    WhitespaceOnlyString -> "whitespace only string"
    InvalidUnderscorePosition(index) ->
      "underscore at invalid position: " <> index |> int.to_string
    InvalidDecimalPosition(index) ->
      "decimal at invalid position: " <> index |> int.to_string
    InvalidSignPosition(sign, index) ->
      "sign \"" <> sign <> "\" at invalid position: " <> index |> int.to_string
    InvalidDigitPosition(digit, index) ->
      "digit \""
      <> digit
      <> "\" at invalid position: "
      <> index |> int.to_string
    OutOfBaseRange(character, value, index) ->
      "digit character \""
      <> character
      <> "\" ("
      <> value |> int.to_string
      <> ") is out of range for the specified base at position "
      <> index |> int.to_string
    InvalidExponentSymbolPosition(exponent_symbol, index) ->
      "exponent symbol \""
      <> exponent_symbol
      <> "\" at invalid position: "
      <> index |> int.to_string
    UnknownCharacter(character, index) ->
      "unknown character \""
      <> character
      <> "\" at index: "
      <> index |> int.to_string
    InvalidBaseValue(base) -> "invalid base value: " <> base |> int.to_string
  }
}
