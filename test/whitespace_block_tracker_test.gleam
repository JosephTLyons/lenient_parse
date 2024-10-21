import gleam/int
import gleam/list
import helpers
import lenient_parse/internal/tokenizer
import lenient_parse/internal/whitespace_block_tracker
import startest.{describe, it}
import startest/expect

pub fn whitespace_block_tracker_tests() {
  describe(
    "whitespace_block_tracker_tests",
    [
      #("        ", 0b0),
      #("123123", 0b1),
      #("1 1 1 1 ", 0b10101010),
      #("  12 \n\t\r\f\r\n3.400  ", 0b1010),
    ]
      |> list.map(fn(tuple) {
        let #(input, output) = tuple
        let printable_text = input |> helpers.to_printable_text
        let output_string = output |> int.to_base2
        use <- it("\"" <> printable_text <> "\" -> 0b" <> output_string)

        input
        |> tokenizer.tokenize_number_string
        |> list.fold(whitespace_block_tracker.new(), fn(tracker, token) {
          tracker |> whitespace_block_tracker.mark(token)
        })
        |> whitespace_block_tracker.state()
        |> expect.to_equal(output)
      }),
  )
}
