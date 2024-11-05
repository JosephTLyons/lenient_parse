import lenient_parse/internal/token.{
  DecimalPoint, Digit, Exponent, Sign, Underscore, Unknown, Whitespace,
}
import lenient_parse/internal/tokenizer.{tokenize}
import startest/expect

pub fn tokenize_test() {
  " \t\n\r\f\r\n+-0123456789eE._abc"
  |> tokenize
  |> expect.to_equal([
    Whitespace(" "),
    Whitespace("\t"),
    Whitespace("\n"),
    Whitespace("\r"),
    Whitespace("\f"),
    Whitespace("\r\n"),
    Sign("+", True),
    Sign("-", False),
    Digit(0),
    Digit(1),
    Digit(2),
    Digit(3),
    Digit(4),
    Digit(5),
    Digit(6),
    Digit(7),
    Digit(8),
    Digit(9),
    Exponent("e"),
    Exponent("E"),
    DecimalPoint,
    Underscore,
    Unknown("a"),
    Unknown("b"),
    Unknown("c"),
  ])
}
