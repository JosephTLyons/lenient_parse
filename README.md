# lenient_parse

[![Package Version](https://img.shields.io/hexpm/v/lenient_parse)](https://hex.pm/packages/lenient_parse)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lenient_parse/)

A Gleam library providing lenient parsing functions for converting strings to float and integer values. This package offers more flexible parsing than the standard Gleam functions, similar to Python's built-in `float()` and `int()` functions.

## Installation


```sh
gleam add lenient_parse
```
```gleam
import lenient_parse
import gleam/io

pub fn main() {
  // --- Float parsing

  // Parse a string containing an integer
  "1" |> to_float |> io.debug
  // Ok(1.0)

  // Parse a string containing a negative float
  "-5.001" |> to_float |> io.debug
  // Ok(-5.001)

  // Parse a more complex float with scientific notation
  "-1_234.567_8e-2" |> to_float |> io.debug
  // -> Ok(-12.345678)

  // --- Integer parsing

  // Parse a string containing an integer
  "123" |> to_int |> io.debug
  // Ok(123)

  // Parse a string containing a negative integer with surrounding whitespace
  "  -123  " |> to_int |> io.debug
  // Ok(-123)

  // Parse a string containing an integer with an underscores
  "1_000_000" |> to_int |> io.debug
  // Ok(1000000)
}
```

## Developer Setup

To run the tests for this package, you'll need to [install `uv`](https://docs.astral.sh/uv/getting-started/installation/).
