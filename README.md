# lenient_parse

[![Package Version](https://img.shields.io/hexpm/v/lenient_parse)](https://hex.pm/packages/lenient_parse)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lenient_parse/)

A Gleam library that replicates the functionality of Python's built-in `float()`
and `int()` functions for parsing strings into float and integer values. Use
`lenient_parse` when `int.parse` and `float.parse` from the Gleam
[stdlib](https://github.com/gleam-lang/stdlib) are too strict.

- `float("3.14")` -> `lenient_parse.to_float("3.14")`
- `int("42")` -> `lenient_parse.to_int("42")`
- `int("1010", base=2)` -> `lenient_parse.to_int_with_base("1010", 2)`

## Installation

```sh
gleam add lenient_parse
```

## Usage

```gleam
import gleam/float
import gleam/int
import gleam/list
import lenient_parse

pub fn main() {
  // Parse a string containing an integer value into a float

  let _ = echo lenient_parse.to_float("1")
  // Ok(1.0)
  let _ = echo float.parse("1")
  // Error(Nil)

  // Parse a string containing a negative float

  let _ = echo lenient_parse.to_float("-5.001")
  // Ok(-5.001)
  let _ = echo float.parse("-5.001")
  // Ok(-5.001)

  // Parse a string containing a complex float with scientific notation

  let _ = echo lenient_parse.to_float("-1_234.567_8e-2")
  // Ok(-12.345678)
  let _ = echo float.parse("-1_234.567_8e-2")
  // Error(Nil)

  // Parse a string containing an integer

  let _ = echo lenient_parse.to_int("123")
  // Ok(123)
  let _ = echo int.parse("123")
  // Ok(123)

  // Parse a string containing a negative integer with surrounding whitespace

  let _ = echo lenient_parse.to_int("  -123  ")
  // Ok(-123)
  let _ = echo int.parse("  -123  ")
  // Error(Nil)

  // Parse a string containing an integer with underscores

  let _ = echo lenient_parse.to_int("1_000_000")
  // Ok(1000000)
  let _ = echo int.parse("1_000_000")
  // Error(Nil)

  // Parse a string containing a binary number with underscores

  let _ = echo lenient_parse.to_int_with_base("1000_0000", 2)
  // Ok(128)
  let _ = echo int.base_parse("1000_0000", 2)
  // Error(Nil)

  // Parse a string containing a hexadecimal number with underscores

  let _ = echo lenient_parse.to_int_with_base("DEAD_BEEF", 16)
  // Ok(3735928559)
  let _ = echo int.base_parse("DEAD_BEEF", 16)
  // Error(Nil)

  // Use base 0 to automatically detect the base when parsing strings with prefix indicators

  let dates = [
    "0b11011110000",
    "0o3625",
    "1865",
    "0x7bc",
    "0B11110110001",
    "1929",
    "0O3507",
    "0X7a9",
    "0b11011111011",
  ]

  let _ = echo list.map(dates, lenient_parse.to_int_with_base(_, 0))
  // [Ok(1776), Ok(1941), Ok(1865), Ok(1980), Ok(1969), Ok(1929), Ok(1863), Ok(1961), Ok(1787)]

  let _ = echo list.map(dates, int.base_parse(_, 0))
  // [Error(Nil), Error(Nil), Error(Nil), Error(Nil), Error(Nil), Error(Nil), Error(Nil), Error(Nil), Error(Nil)]

  // Nice errors

  let _ = echo lenient_parse.to_float("12.3e_3")
  // Error(InvalidUnderscorePosition(5))
  let _ = echo float.parse("12.3e_3")
  // Error(Nil)
}
```

## [Rigorous Testing](https://github.com/JosephTLyons/lenient_parse/tree/main/test/data)

`lenient_parse`'s testing is extensive. We test the tokenization step, the
overall parse procedure, as well as various intermediate layers. We currently
have ~600 passing tests. Regressions are **not** welcome here.

### Backed by Python

Each test input is also processed using Python's (3.13) `float()` and `int()`
functions. We verify that `lenient_parse` produces the same output as Python. If
Python's built-ins succeed, `lenient_parse` should also succeed with identical
results. If Python's built-ins fail to parse, `lenient_parse` should also fail.
This ensures that `lenient_parse` behaves consistently with Python's built-ins
for all supplied test data. Tests are run against both the Erlang and JavaScript
targets.

If you run into a case where `lenient_parse` and Python's built-ins disagree,
please open an [issue](https://github.com/JosephTLyons/lenient_parse/issues) -
we aim to be 100% consistent with Python's built-ins and we will fix any
reported discrepancies.

## Development

To run the tests for this package, you'll need to [install
`uv`](https://docs.astral.sh/uv/getting-started/installation/).
