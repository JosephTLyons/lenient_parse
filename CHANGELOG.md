# Changelog

## v1.2.0 - XXXX-XXX-XX

- Added a new `OutOfBoundsDigit` error that represents a digit that is higher than the base.

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
