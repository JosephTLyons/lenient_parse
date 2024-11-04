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

  /// Represents an error when a digit is in an invalid position within
  /// the number string.
  ///
  /// - `character`: The digit character that caused the error as a `String`.
  /// - `index`: The position of the invalid digit in the input string.
  InvalidDigitPosition(character: String, index: Int)

  /// Represents an error when an invalid character is encountered during
  /// parsing.
  ///
  /// - `character`: The invalid character as a `String`.
  /// - `index`: The position of the invalid character in the input string.
  InvalidCharacter(character: String, index: Int)

  /// Represents an error when Gleam's `float.parse` fails after custom parsing
  /// and coercion.
  ///
  /// This indicates that the string couldn't be converted to a float even with
  /// more permissive rules.
  GleamFloatParseError

  /// Represents an error when Gleam's `int.parse` fails after custom parsing
  /// and coercion.
  ///
  /// This indicates that the string couldn't be converted to an integer even
  /// with more permissive rules.
  GleamIntParseError
}

@internal
pub fn to_string(error: ParseError) -> String {
  case error {
    GleamIntParseError -> "gleam integer parse error"
    InvalidCharacter(character, index) ->
      "invalid character \""
      <> character
      <> "\" at index: "
      <> index |> int.to_string
    InvalidUnderscorePosition(index) ->
      "invalid underscore at position: " <> index |> int.to_string
    EmptyString -> "empty string"
    WhitespaceOnlyString -> "whitespace only string"
    GleamFloatParseError -> "gleam float parse error"
    InvalidDecimalPosition(index) ->
      "invalid decimal at position: " <> index |> int.to_string
    InvalidSignPosition(sign, index) ->
      "invalid sign \"" <> sign <> "\" at position: " <> index |> int.to_string
    InvalidDigitPosition(digit, index) ->
      "invalid digit \""
      <> digit
      <> "\" at position: "
      <> index |> int.to_string
  }
}
