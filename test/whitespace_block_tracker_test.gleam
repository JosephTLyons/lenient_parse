import gleam/list
import lenient_parse/internal/tokenizer
import lenient_parse/internal/whitespace_block_tracker
import startest/expect

// TODO: Convert to describe-style data-driven tests

pub fn whitespace_block_tracker_test() {
  "        "
  |> build_tracker_int
  |> expect.to_equal(0b0)

  "123123"
  |> build_tracker_int
  |> expect.to_equal(0b1)

  "1 1 1 1 "
  |> build_tracker_int
  |> expect.to_equal(0b10101010)

  "  12  3.400  "
  |> build_tracker_int
  |> expect.to_equal(0b1010)
}

fn build_tracker_int(text: String) -> Int {
  text
  |> tokenizer.tokenize_number_string
  |> list.fold(whitespace_block_tracker.new(), fn(tracker, token) {
    tracker |> whitespace_block_tracker.mark(token)
  })
}
