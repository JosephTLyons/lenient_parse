import lenient_parse/internal/tokenizer.{
  DecimalPoint, Digit, Sign, Underscore, Unknown, Whitespace,
  tokenize_number_string,
}
import startest/expect

pub fn tokenize_number_string_test() {
  " \t\n\r\f+-0123456789._abc"
  |> tokenize_number_string
  |> expect.to_equal([
    Whitespace(" "),
    Whitespace("\t"),
    Whitespace("\n"),
    Whitespace("\r"),
    Whitespace("\f"),
    Sign("+"),
    Sign("-"),
    Digit("0"),
    Digit("1"),
    Digit("2"),
    Digit("3"),
    Digit("4"),
    Digit("5"),
    Digit("6"),
    Digit("7"),
    Digit("8"),
    Digit("9"),
    DecimalPoint,
    Underscore,
    Unknown("a"),
    Unknown("b"),
    Unknown("c"),
  ])
}
