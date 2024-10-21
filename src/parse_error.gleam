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

  /// Represents an error when an invalid character is encountered during
  /// parsing.
  ///
  /// - `character`: The invalid character as a `String`.
  /// - `index`: The position of the invalid character in the input string.
  InvalidCharacter(character: String, index: Int)

  /// This is a fallback error that occurs when `lenient_parse` fails to coerce
  /// the input string into a form that Gleam's `float.parse` can handle. This
  /// should be seen as a bug.
  FailureToParseFloat

  /// This is a fallback error that occurs when `lenient_parse` fails to coerce
  /// the input string into a form that Gleam's `int.parse` can handle. This
  /// should be seen as a bug.
  FailureToParseInt
}

@internal
pub fn to_string(error: ParseError) -> String {
  case error {
    EmptyString -> "empty string"
    WhitespaceOnlyString -> "whitespace only string"
    InvalidUnderscorePosition(index) ->
      "invalid underscore at position: " <> index |> int.to_string
    InvalidDecimalPosition(index) ->
      "invalid decimal at position: " <> index |> int.to_string
    InvalidSignPosition(sign, index) ->
      "invalid sign \"" <> sign <> "\" at position: " <> index |> int.to_string
    InvalidCharacter(character, index) ->
      "invalid character \""
      <> character
      <> "\" at index: "
      <> index |> int.to_string
    FailureToParseFloat -> "failure to parse float"
    FailureToParseInt -> "failure to parse int"
  }
}
