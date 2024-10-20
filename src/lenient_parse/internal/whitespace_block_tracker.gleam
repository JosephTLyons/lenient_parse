import gleam/int
import lenient_parse/internal/tokenizer.{type Token, Whitespace}

// TODO: Better name

pub opaque type WhitespaceBlockTracker {
  WhitespaceBlockTracker(state: Int)
}

pub fn new() -> WhitespaceBlockTracker {
  WhitespaceBlockTracker(0)
}

pub fn state(tracker: WhitespaceBlockTracker) -> Int {
  tracker.state
}

pub fn mark(
  tracker: WhitespaceBlockTracker,
  token: Token,
) -> WhitespaceBlockTracker {
  let state = case token, tracker.state % 2 == 0 {
    Whitespace(_), True -> tracker.state
    Whitespace(_), False -> tracker.state |> int.bitwise_shift_left(1)
    _, True -> { tracker.state |> int.bitwise_shift_left(1) } + 1
    _, False -> tracker.state
  }

  WhitespaceBlockTracker(state)
}
