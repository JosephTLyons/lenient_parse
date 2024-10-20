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
  "1" |> lenient_parse.to_float |> io.debug
  // Ok(1.0)

  "1.001" |> lenient_parse.to_float |> io.debug
  // Ok(1.001)

  "+123.321" |> lenient_parse.to_float |> io.debug
  // Ok(123.321)

  "-123.321" |> lenient_parse.to_float |> io.debug
  // Ok(-123.321)

  "1_000_000.0" |> lenient_parse.to_float |> io.debug
  // Ok(1.0e6)

  "123" |> lenient_parse.to_int |> io.debug
  // Ok(123)

  "+123" |> lenient_parse.to_int |> io.debug
  // Ok(123)

  "-123" |> lenient_parse.to_int |> io.debug
  // Ok(-123)

  "1_000_000" |> lenient_parse.to_int |> io.debug
  // Ok(1000000)
}
```

## Developer Setup

To run the tests for this package, you'll need to [install `uv`](https://docs.astral.sh/uv/getting-started/installation/).
