# Changelog

## v1.3.0 - XXXX-XX-XX

- Added base 0 support to `lenient_parse.to_int_with_base`. When providing a base of 0, the function will look for a base prefix string (`0b`, `0o`, `0x`) to try to determine the base value. If no prefix is found, the function will default to base 10.

## v1.2.0 - 2024-11-09

- Added arbitrary base support for integer parsing - use pub `lenient_parse.to_int_with_base`.
- Introduced `OutOfBaseRange` and `InvalidBaseValue` errors.

## v1.1.0 - 2024-11-07

- Added support for scientific notation for float parsing.
    - Ex: `lenient_parse.to_float("4e-3")` // Ok(0.004)
- Implemented a new recursive descent parser.
- Breaking changes:
    - `GleamIntParseError` and `GleamIntParseErrorReason` have been removed.
    - `InvalidCharacter` has been renamed to `UnknownCharacter`.
    - A new `InvalidDigitPosition` error has been introduced.

## v1.0.2 - 2024-10-20

- Fixed bugs.
- Return custom error types for various parsing errors instead of simply `Nil`.
- Reworked internal algorithm for more robust parsing.

## v1.0.1 - 2024-10-10

- Added more examples to `README.md`.

## v1.0.0 - 2024-10-10

- Initial release.
