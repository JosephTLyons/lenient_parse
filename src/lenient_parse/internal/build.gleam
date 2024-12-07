import bigi
import gleam/bool
import gleam/deque.{type Deque}
import gleam/int
import gleam/list
import gleam/string
import lenient_parse/internal/base_constants.{base_10}
import lenient_parse/internal/convert
import lenient_parse/internal/pilkku/pilkku
import lenient_parse/internal/scale
import parse_error.{type ParseError, OutOfFloatRange, OutOfIntRange}

pub fn float_value(
  is_positive is_positive: Bool,
  whole_digits whole_digits: Deque(Int),
  fractional_digits fractional_digits: Deque(Int),
  scale_factor scale_factor: Int,
) -> Result(Float, ParseError) {
  let #(whole_digits, fractional_digits) =
    scale.deques(whole_digits, fractional_digits, scale_factor)
  let exponent = fractional_digits |> deque.length
  let #(digits, _) = scale.deques(whole_digits, fractional_digits, exponent)

  // `bigi.undigits` documentation says it can fail if:
  // - the base is less than 2: We are hardcoding base 10, so this doesn't
  //   apply.
  // - if the digits are out of range for the given base: For float parsing, the
  //   tokenizer has already marked these digits as `Unknown` tokens and the
  //   parser has already raised an error. Therefore, the error case here should
  //   be unreachable. We do not want to `let assert Ok()`, just in case there
  //   is some bug in the prior code. Using the fallback will result in some
  //   precision loss, but it is better than crashing. We may want to raise an
  //   actual error in the future.
  let digits_list = digits |> deque.to_list
  case digits_list |> bigi.undigits(base_10) {
    Ok(coefficient) -> {
      let sign =
        case is_positive {
          True -> 1
          False -> -1
        }
        |> bigi.from_int

      let decimal =
        pilkku.new_bigint(
          sign:,
          coefficient:,
          exponent: bigi.from_int(-exponent),
        )

      case decimal |> pilkku.to_float {
        Ok(float_value) if float_value == 0.0 && !is_positive -> Ok(-0.0)
        Ok(float_value) -> Ok(float_value)
        // TODO: Add tests that hit this case? Might be hard
        Error(_) -> {
          let float_string =
            build_float_string_representation(
              whole_digits: whole_digits |> deque.to_list,
              fractional_digits: fractional_digits |> deque.to_list,
              is_positive: is_positive,
            )
          Error(OutOfFloatRange(float_string))
        }
      }
    }
    // Fallback to logic that can result in slight rounding issues
    // Should be unreachable
    Error(_) -> {
      let float_value =
        digits
        |> convert.digits_to_int
        |> int.to_float
        |> scale.float(-exponent)
      use <- bool.guard(is_positive, Ok(float_value))
      Ok(float_value *. -1.0)
    }
  }
}

pub fn integer_value(
  digits digits: Deque(Int),
  base base: Int,
  is_positive is_positive: Bool,
) -> Result(Int, ParseError) {
  // `bigi.undigits` documentation says it can fail if:
  // - the base is less than 2: We've already ensured that the user has picked
  //    a base >= 2 and <= 36, so this doesn't apply.
  // - if the digits are out of range for the given base: For integer parsing,
  //   the tokenizer has already marked these digits as `Unknown` tokens and the
  //   parser has already raised an error. Therefore, the error case here should
  //   be unreachable. We do not want to `let assert Ok()`, just in case there
  //   is some bug in the prior code. If the fallback is hit, issues may arise
  //   on JavaScript. We may want to raise an actual error in the future.
  let digits_list = digits |> deque.to_list
  case digits_list |> bigi.undigits(base) {
    Ok(big_int) ->
      case big_int |> bigi.to_int {
        Ok(value) -> {
          let value = case is_positive {
            True -> value
            False -> -value
          }
          Ok(value)
        }
        Error(_) -> {
          let integer_string =
            digits_list |> build_int_string_representation(is_positive)
          Error(OutOfIntRange(integer_string))
        }
      }
    // Fallback to logic that can result in incorrect integer values for
    // JavaScript.
    // Should be unreachable
    Error(_) -> {
      let value = digits |> convert.digits_to_int_with_base(base)
      let value = case is_positive {
        True -> value
        False -> -value
      }
      Ok(value)
    }
  }
}

fn build_float_string_representation(
  whole_digits whole_digits: List(Int),
  fractional_digits fractional_digits: List(Int),
  is_positive is_positive: Bool,
) {
  let whole_string = whole_digits |> list.map(int.to_string) |> string.join("")
  let fractional_string =
    fractional_digits |> list.map(int.to_string) |> string.join("")

  case is_positive {
    True -> whole_string <> "." <> fractional_string
    False -> "-" <> whole_string <> "." <> fractional_string
  }
}

fn build_int_string_representation(
  digits_list digits_list: List(Int),
  is_positive is_positive: Bool,
) {
  let integer_string = digits_list |> list.map(int.to_string) |> string.join("")

  case is_positive {
    True -> integer_string
    False -> "-" <> integer_string
  }
}
// TODO: For float, test limits and raise error
// TODO: Test erlang before and after negative safe integer check
// TODO: Test javascript before and after invalid base value check

// TODO: Unify the code between build_int and build_float
