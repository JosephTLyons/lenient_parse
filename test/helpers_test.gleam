import gleam/list
import helpers.{into_printable_text}
import startest.{describe, it}
import startest/expect

// TODO: Make this whole file internal

pub fn into_printable_text_tests() {
  describe(
    "should_be_printable_text_test",
    [
      [
        #("\t", "\\t"),
        #("\n", "\\n"),
        #("\r", "\\r"),
        #("\f", "\\f"),
        #("\t\nabc123\r", "\\t\\nabc123\\r"),
      ]
      |> list.map(fn(pair) {
        let #(input, output) = pair
        use <- it("\"" <> output <> "\"")
        input |> into_printable_text |> expect.to_equal(output)
      }),
    ]
      |> list.concat,
  )
}
