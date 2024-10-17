pub type ParseError {
  /// Represents an error when an invalid character is encountered during
  /// parsing. The `String` parameter contains the invalid character.
  InvalidCharacter(String)

  /// Represents an error when the input string is empty or contains only
  /// whitespace.
  WhitespaceOnlyOrEmptyString

  /// Represents an error when an underscore is in an invalid position within
  /// the number string.
  InvalidUnderscorePosition

  /// Represents an error when a decimal point is in an invalid position within
  /// the number string.
  InvalidDecimalPosition

  /// Represents an error when a sign (+ or -) is in an invalid position within
  /// the number string. The `String` parameter contains the sign that caused
  /// the error.
  SignAtInvalidPosition(String)

  /// Represents an error when Gleam's `float.parse` fails after custom parsing
  /// and coercion. Indicates the string couldn't be converted to a float even
  /// with more permissive rules.
  GleamFloatParseError

  /// Represents an error when Gleam's `int.parse` fails after custom parsing
  /// and coercion. Indicates the string couldn't be converted to a float even
  /// with more permissive rules.
  GleamIntParseError
}

@internal
pub fn parse_error_to_string(error: ParseError) -> String {
  case error {
    GleamIntParseError -> "GleamIntParseError"
    InvalidCharacter(character) -> "InvalidCharacter(\"" <> character <> "\")"
    InvalidUnderscorePosition -> "InvalidUnderscorePosition"
    WhitespaceOnlyOrEmptyString -> "WhitespaceOnlyOrEmptyString"
    GleamFloatParseError -> "GleamFloatParseError"
    InvalidDecimalPosition -> "InvalidDecimalPosition"
    SignAtInvalidPosition(character) ->
      "SignAtInvalidPosition(\"" <> character <> "\")"
  }
}
