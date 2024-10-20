import gleam/int
import lenient_parse/internal/tokenizer.{type Token, Whitespace}

// TODO: Better name

pub type WhitespaceBlockTracker =
  Int

pub fn new() -> WhitespaceBlockTracker {
  0
}

pub fn mark(
  tracker: WhitespaceBlockTracker,
  token: Token,
) -> WhitespaceBlockTracker {
  case token, tracker % 2 == 0 {
    Whitespace(_), True -> tracker
    Whitespace(_), False -> tracker |> int.bitwise_shift_left(1)
    _, True -> { tracker |> int.bitwise_shift_left(1) } + 1
    _, False -> tracker
  }
}
