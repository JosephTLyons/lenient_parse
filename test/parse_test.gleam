import gleam/string
import gleeunit/should
import lenient_parse.{
  AdjacentUnderscores, InvalidCharacter, LeadingUnderscore, TrailingUnderscore,
  UnderscoreNextToDecimal, WhitespaceOnlyOrEmptyString,
}

pub fn coerce_into_valid_number_string_test() {
  ""
  |> lenient_parse.coerce_into_valid_number_string
  |> should.equal(Error(WhitespaceOnlyOrEmptyString))

  " "
  |> lenient_parse.coerce_into_valid_number_string
  |> should.equal(Error(WhitespaceOnlyOrEmptyString))
}

pub fn has_valid_characters_test() {
  lenient_parse.valid_characters
  |> string.join("")
  |> lenient_parse.has_valid_characters
  |> should.equal(Ok(Nil))

  "a"
  |> lenient_parse.has_valid_characters
  |> should.equal(Error(InvalidCharacter("a")))

  "1a1"
  |> lenient_parse.has_valid_characters
  |> should.equal(Error(InvalidCharacter("a")))
}

pub fn check_for_valid_underscore_position_test() {
  "1_000"
  |> lenient_parse.check_for_valid_underscore_position
  |> should.equal(Ok(Nil))

  "1__000"
  |> lenient_parse.check_for_valid_underscore_position
  |> should.equal(Error(AdjacentUnderscores))

  "1_.000"
  |> lenient_parse.check_for_valid_underscore_position
  |> should.equal(Error(UnderscoreNextToDecimal))

  "1._000"
  |> lenient_parse.check_for_valid_underscore_position
  |> should.equal(Error(UnderscoreNextToDecimal))

  "_1000"
  |> lenient_parse.check_for_valid_underscore_position
  |> should.equal(Error(LeadingUnderscore))

  "1000_"
  |> lenient_parse.check_for_valid_underscore_position
  |> should.equal(Error(TrailingUnderscore))

  "-_1000"
  |> lenient_parse.check_for_valid_underscore_position
  |> should.equal(Error(TrailingUnderscore))
}
