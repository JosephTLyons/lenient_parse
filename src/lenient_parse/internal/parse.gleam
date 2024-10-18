import gleam/float
import gleam/int
import gleam/result
import parse_error.{type ParseError, GleamFloatParseError, GleamIntParseError}

pub fn to_float(
  text: String,
  coerce_strategy: fn(String) -> Result(String, ParseError),
) -> Result(Float, ParseError) {
  let text = text |> coerce_strategy
  use text <- result.try(text)
  let res = text |> float.parse |> result.replace_error(GleamFloatParseError)
  use <- result.lazy_or(res)

  text
  |> int.parse
  |> result.map(int.to_float)
  |> result.replace_error(GleamIntParseError)
}

pub fn to_int(
  text: String,
  coerce_strategy: fn(String) -> Result(String, ParseError),
) -> Result(Int, ParseError) {
  use text <- result.try(text |> coerce_strategy)
  text |> int.parse |> result.replace_error(GleamIntParseError)
}
