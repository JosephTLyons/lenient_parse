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
    InvalidExponentSymbolPosition(exponent, index) ->
      "exponent symbol \""
      <> exponent
      <> "\" at invalid position: "
      <> index |> int.to_string
    UnknownCharacter(character, index) ->
      "unknown character \""
      <> character
      <> "\" at index: "
      <> index |> int.to_string
  }
}
