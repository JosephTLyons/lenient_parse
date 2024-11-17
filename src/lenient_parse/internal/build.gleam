import bigi
import gleam/bool
import gleam/int
import gleam/queue.{type Queue}
import lenient_parse/internal/base_constants.{base_10}
import lenient_parse/internal/convert
import lenient_parse/internal/scale
import pilkku

pub fn float_value(
  is_positive is_positive: Bool,
  whole_digits whole_digits: Queue(Int),
  fractional_digits fractional_digits: Queue(Int),
  scale_factor scale_factor: Int,
) -> Float {
  let #(whole_digits, fractional_digits) =
    scale.queues(whole_digits, fractional_digits, scale_factor)
  let exponent = fractional_digits |> queue.length
  let #(digits, _) = scale.queues(whole_digits, fractional_digits, exponent)

  // `bigi.undigits` documentation says it can fail if:
  // - the base is less than 2: We are hardcoding base 10, so this doesn't apply
  // - if the digits are out of range for the given base: For float parsing, the
  //   tokenizer has already marked these digits as `Unknown` tokens and the
  //   parser has already raised an error. Therefore, the error case here should
  //   be unreachable. We do not want to `let assert Ok()`, just in case there
  //   is some bug in the prior code. Using the fallback will result in some
  //   precision loss, but it is better than crashing.
  let float_value = case digits |> queue.to_list |> bigi.undigits(base_10) {
    Ok(coefficient) -> {
      let sign =
        case is_positive {
          True -> 1
          False -> -1
        }
        |> bigi.from_int

      let decimal =
        pilkku.new_bigint(
          sign: sign,
          coefficient: coefficient,
          exponent: bigi.from_int(-exponent),
        )

      case decimal |> pilkku.to_float {
        Ok(float_value) if float_value == 0.0 && !is_positive -> Ok(-0.0)
        Ok(float_value) -> Ok(float_value)
        Error(_) -> Error(Nil)
      }
    }
    Error(_) -> Error(Nil)
  }

  case float_value {
    Ok(float_value) -> float_value
    // Fallback to logic that can result in slight rounding issues
    Error(_) -> {
      let float_value =
        digits
        |> convert.digits_to_int
        |> int.to_float
        |> scale.float(-exponent)
      use <- bool.guard(is_positive, float_value)
      float_value *. -1.0
    }
  }
}
