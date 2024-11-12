# lenient_parse

[![Package Version](https://img.shields.io/hexpm/v/lenient_parse)](https://hex.pm/packages/lenient_parse)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lenient_parse/)

A Gleam library providing lenient parsing functions for converting strings to
float and integer values. This package offers more flexible parsing than the
standard Gleam functions, similar to Python's built-in `float()` and `int()`
functions.

## Installation

```sh
gleam add lenient_parse
```

## Usage

```gleam
import gleam/float
import gleam/int
import gleam/io
import lenient_parse

pub fn main() {
  // Parse a string containing an integer value into a float

  "1" |> lenient_parse.to_float |> io.debug // Ok(1.0)
  "1" |> float.parse |> io.debug // Error(Nil)

  // Parse a string containing a negative float

  "-5.001" |> lenient_parse.to_float |> io.debug // Ok(-5.001)
  "-5.001" |> float.parse |> io.debug // Ok(-5.001)

  // Parse a string containing a complex float with scientific notation

  "-1_234.567_8e-2" |> lenient_parse.to_float |> io.debug // Ok(-12.345678)
  "-1_234.567_8e-2" |> float.parse |> io.debug // Error(Nil)

  // Parse a string containing an integer

  "123" |> lenient_parse.to_int |> io.debug // Ok(123)
  "123" |> int.parse |> io.debug // Ok(123)

  // Parse a string containing a negative integer with surrounding whitespace

  "  -123  " |> lenient_parse.to_int |> io.debug // Ok(-123)
  "  -123  " |> int.parse |> io.debug // Error(Nil)

  // Parse a string containing an integer with underscores

  "1_000_000" |> lenient_parse.to_int |> io.debug // Ok(1000000)
  "1_000_000" |> int.parse |> io.debug // Error(Nil)

  // Parse a string containing a binary number with underscores

  "1000_0000" |> lenient_parse.to_int_with_base(base: 2) |> io.debug // Ok(128)
  "1000_0000" |> int.base_parse(2) |> io.debug // Error(Nil)

  // Parse a string containing a hexadecimal number with underscores

  "DEAD_BEEF" |> lenient_parse.to_int_with_base(base: 16) |> io.debug // Ok(3735928559)
  "DEAD_BEEF" |> int.base_parse(16) |> io.debug // Error(Nil)

  // Use base 0 to automatically detect the base when parsing strings with prefix indicators

  "0b10" |> lenient_parse.to_int_with_base(base: 0) |> io.debug // Ok(2)
  "0b10" |> int.base_parse(0) |> io.debug // Error(Nil)

  "0o01234" |> lenient_parse.to_int_with_base(base: 0) |> io.debug // Ok(668)
  "0o01234" |> int.base_parse(0) |> io.debug // Error(Nil)

  "0xDEADBEEF" |> lenient_parse.to_int_with_base(base: 0) |> io.debug // Ok(3735928559)
  "0xDEADBEEF" |> int.base_parse(0) |> io.debug // Error(Nil)

  // If no prefix string is present, base 0 defaults to base 10

  "-4" |> lenient_parse.to_int_with_base(base: 0) |> io.debug // Ok(-4)
  "-4" |> int.base_parse(0) |> io.debug // Error(Nil)

  // Nice errors

  "12.3e_3" |> lenient_parse.to_float |> io.debug // Error(InvalidUnderscorePosition(5))
  "12.3e_3" |> float.parse |> io.debug // Error(Nil)
}
```

## Rigorous Testing

`lenient_parse`'s [testing is
extensive](https://github.com/JosephTLyons/lenient_parse/tree/main/test/data).
Each test input is also processed using Python's (3.13) `float()` and `int()`
functions. We verify that `lenient_parse` produces the same output as Python. If
Python's built-ins succeed, `lenient_parse` should also succeed with identical
results. If Python's built-ins fail to parse, `lenient_parse` should also fail.
This ensures that `lenient_parse` behaves consistently with Python's built-ins
for all supplied test data.

## Development

To run the tests for this package, you'll need to [install
`uv`](https://docs.astral.sh/uv/getting-started/installation/).
