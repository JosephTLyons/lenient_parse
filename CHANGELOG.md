# Changelog

## v2.0.0 - 2024-12-07

- Handled values that exceed either the `Number.MIN_SAFE_INTEGER` and `Number.MAX_SAFE_INTEGER` limits on the JavaScript target.
- Handled values that cannot fit within the float type, on both Erlang and JavaScript targets.

This is a breaking change, as we introduced new errors to `ParseError`, which will affect users who are matching on the `ParseError` type.
    - `OutOfIntRange`
    - `OutOfFloatRange`

## v1.3.5 - 2024-11-20

- Fixed a bug where base prefix substrings would be recognized as such later in the string.
    - The `0b` in `0XDEAD_BEEF0b` should be catorgized as digits and not a base prefix.
- Fixed a bug where, in base 0 mode, `lenient_parse` would parse a string with an incomplete base prefix.
    - `01` should reject, as it is missing a specifier (`b`, `B`, `o`, `O`, `x`, `X`).

## v1.3.4 - 2024-11-19

- Fixed a bug where `lenient_parse` was rejecting strings containing leading / trailing uncommon whitespace characters.

## v1.3.3 - 2024-11-18

- Fixed precision errors. We now rely on `bigi` and `pilkku` to construct the final float representation.

## v1.3.2 - 2024-11-15

- Fixed precision errors in some float representations by removing the need to add together the integer and fractional parts of a float.

## v1.3.1 - 2024-11-11

- Fixed a bug where an underscore was not allowed in between a base prefix string and the number: `0x_DEAD_BEEF` should parse.

## v1.3.0 - 2024-11-11

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
