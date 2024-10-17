import gleam/list
import helpers.{to_printable_text}
import startest.{describe, it}
import startest/expect

pub fn to_printable_text_tests() {
  describe(
    "should_be_printable_text",
    [
      #("\t", "\\t"),
      #("\n", "\\n"),
      #("\r", "\\r"),
      #("\f", "\\f"),
      #("\t\nabc123\r", "\\t\\nabc123\\r"),
    ]
      |> list.map(fn(tuple) {
        let #(input, output) = tuple
        use <- it("\"" <> output <> "\"")
        input |> to_printable_text |> expect.to_equal(output)
      }),
  )
}
