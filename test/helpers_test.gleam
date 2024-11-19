import gleam/dict
import gleam/list
import helpers
import lenient_parse/internal/whitespace
import startest.{describe, it}
import startest/expect

pub fn to_printable_text_tests() {
  let whitespace_tuples =
    whitespace.character_dict()
    |> dict.to_list
    |> list.map(fn(a) { #({ a.1 }.character, { a.1 }.printable) })

  describe(
    "should_be_printable_text",
    [
      #("\t", "\\t"),
      #("\n", "\\n"),
      #("\r", "\\r"),
      #("\f", "\\x0c"),
      #("\r\n", "\\r\\n"),
      #("\t\nabc123\r", "\\t\\nabc123\\r"),
      #("abc123\r\n", "abc123\\r\\n"),
    ]
      |> list.append(whitespace_tuples)
      |> list.map(fn(tuple) {
        let #(input, output) = tuple
        use <- it("\"" <> output <> "\"")
        input |> helpers.to_printable_text |> expect.to_equal(output)
      }),
  )
}
