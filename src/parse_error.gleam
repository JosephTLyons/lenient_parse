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
  /// - `index`: The position of the invalid sign in the input string.
  /// - `character`: The sign character that caused the error as a `String`.
  InvalidSignPosition(index: Int, character: String)

  /// Represents an error when a digit is in an invalid position within the
  /// number string.
  ///
  /// - `index`: The position of the invalid digit in the input string.
  /// - `character`: The digit character that caused the error as a `String`.
  InvalidDigitPosition(index: Int, character: String)

  /// Represents an error when the user specifies base = 0, but the input string
  /// only contains a base prefix (`0b`, `0o`, 0x), and no value.
  ///
  /// - `index_range`: The position range of the prefix in the input string.
  /// - `prefix`: The base prefix as a `String`.
  BasePrefixOnly(index_range: #(Int, Int), prefix: String)

  /// Represents an error when a digit character is out of the valid range for
  /// the specified base.
  ///
  /// - `index`: The position of the out-of-range digit in the input string.
  /// - `character`: The string representation of the out-of-range digit.
  /// - `value`: The integer value of the out-of-range digit.
  /// - `base`: The base in which the digit is out of range.
  OutOfBaseRange(index: Int, character: String, value: Int, base: Int)

  /// Represents an error when an exponent symbol (e or E) is in an invalid
  /// position within the number string.
  ///
  /// - `index`: The position of the invalid exponent symbol in the input
  /// string.
  /// - `character`: The exponent symbol that caused the error as a `String`.
  InvalidExponentSymbolPosition(index: Int, character: String)

  /// Represents an error when an invalid character is encountered during
  /// parsing.
  ///
  /// - `index`: The position of the invalid character in the input string.
  /// - `character`: The invalid character as a `String`.
  UnknownCharacter(index: Int, character: String)

  /// Represents an error when the base provided for parsing is invalid.
  ///
  /// - `base`: The invalid base as an `Int`. The base must be between 2 and 36
  /// inclusive.
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
    InvalidSignPosition(index, sign) ->
      "sign \"" <> sign <> "\" at invalid position: " <> index |> int.to_string
    InvalidDigitPosition(index, digit) ->
      "digit \""
      <> digit
      <> "\" at invalid position: "
      <> index |> int.to_string
    BasePrefixOnly(#(start_index, end_index), prefix) ->
      "inferred base prefix only: "
      <> prefix
      <> " at index range: "
      <> start_index |> int.to_string
      <> ".."
      <> end_index |> int.to_string
    OutOfBaseRange(index, character, value, base) ->
      "digit character \""
      <> character
      <> "\" ("
      <> value |> int.to_string
      <> ") at position "
      <> index |> int.to_string
      <> " is out of range for base: "
      <> base |> int.to_string
    InvalidExponentSymbolPosition(index, exponent_symbol) ->
      "exponent symbol \""
      <> exponent_symbol
      <> "\" at invalid position: "
      <> index |> int.to_string
    UnknownCharacter(index, character) ->
      "unknown character \""
      <> character
      <> "\" at index: "
      <> index |> int.to_string
    InvalidBaseValue(base) -> "invalid base value: " <> base |> int.to_string
  }
}
