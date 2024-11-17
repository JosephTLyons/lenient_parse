//// Decimal arithmetic on arbitrary precision floating-point numbers.
////
//// A number is represented by a signed coefficient and exponent such that:
//// `sign * coefficient * 10 ^ exponent`. All numbers are represented and calculated
//// exactly, but the result of an operation may be rounded depending on the
//// context the operation is performed with, see: `pilkku.Context`. Trailing
//// zeros in the coefficient are never truncated to preserve the number of
//// significant digits unless explicitly done so.
////
//// -0 and +0 are two distinct values.
//// Some operation results are not defined and will return an error.
////
//// Exceptional conditions are grouped into signals, each signal has a flag and a
//// trap enabler in the context. Whenever a signal is triggered it's flag is set
//// for the resulting decimal and will be set until explicitly cleared. If the
//// context has a trap enabled for that signal, an error will be returned.
////
//// ## Specifications
////
////   * [IBM's General Decimal Arithmetic Specification](http://speleotrove.com/decimal/decarith.html)
////   * [IEEE standard 854-1987](http://web.archive.org/web/20150908012941/http://754r.ucbtest.org/standards/854.pdf)
////
//// This library follows the above specifications for reference of arithmetic
//// operation implementations, but the public APIs may differ to provide a
//// more idiomatic Gleam interface.
////
//// The specification models the sign of the number as 1, for a negative number,
//// and 0 for a positive number. Internally this implementation models the sign as
//// 1 or -1 such that the complete number will be `sign * coefficient *
//// 10 ^ exponent` and will refer to the sign in documentation as either *positive*
//// or *negative*.
////
//// There is currently no maximum or minimum values for the exponent. Because of
//// that all numbers are "normal". This means that when an operation should,
//// according to the specification, return a number that "underflows" 0 is returned
//// instead of Etiny. Additionally, overflow, underflow and clamped may never
//// be signalled.

// Originally © Eric Meadows-Jönsson and contributors, translated from original
// source at https://github.com/ericmj/decimal/blob/045403e85a3eaaeec23f63cd884d785ca5cf5324/lib/decimal.ex

import bigi.{type BigInt}
import gleam/order
import gleam/result
import gleam/set.{type Set}
import pilkku/context.{type Signal}

const power_of_2_to_52 = 4_503_599_627_370_496

/// An error that occurred in a cast operation.
pub type CastError {
  /// The cast operation would have lost precision.
  LossOfPrecision
  /// The decimal is too big or small to fit in the type.
  OutOfRange
}

type Coefficient =
  BigInt

type Exponent =
  BigInt

type Sign =
  BigInt

pub opaque type Decimal {
  Decimal(
    sign: Sign,
    coefficient: Coefficient,
    exponent: Exponent,
    flags: Set(Signal),
  )
}

/// Create a decimal from a sign, coefficient, and exponent.
///
/// This function takes in [bigi](https://hexdocs.pm/bigi/index.html) `BigInt`s,
/// so it will support integers of any size on both compile targets.
pub fn new_bigint(
  sign sign: BigInt,
  coefficient coefficient: BigInt,
  exponent exponent: BigInt,
) {
  let sign = case bigi.compare(sign, bigi.zero()) {
    order.Lt -> bigi.from_int(-1)
    _ -> bigi.from_int(1)
  }

  Decimal(
    sign: sign,
    coefficient: coefficient,
    exponent: exponent,
    flags: set.new(),
  )
}

/// Cast the decimal into a float.
///
/// The returned float may have lower precision than the decimal. If the decimal
/// cannot fit into a float type, `OutOfRange` is returned.
pub fn to_float(decimal: Decimal) {
  // Convert back to float without loss
  // http://www.exploringbinary.com/correct-decimal-to-floating-point-using-big-integers/
  let f2 = bigi.from_int(52)
  let #(num, den) = ratio(decimal.coefficient, decimal.exponent)
  let boundary = bigi.bitwise_shift_left(den, 52)
  case num == bigi.zero() {
    True -> Ok(0.0)
    False -> {
      let one = bigi.from_int(1)
      case bigi.compare(num, boundary) {
        order.Gt | order.Eq -> {
          let #(den, exp) = scale_down(num, boundary, f2, one)
          decimal_to_float(decimal.sign, num, den, exp)
        }
        _ -> {
          let #(num, exp) = scale_up(num, boundary, f2, bigi.from_int(1))
          decimal_to_float(decimal.sign, num, den, exp)
        }
      }
    }
  }
}

fn scale_up(num: BigInt, den: BigInt, exp: BigInt, one: BigInt) {
  case bigi.compare(num, den) {
    order.Gt | order.Eq -> #(num, exp)
    order.Lt ->
      scale_up(
        bigi.bitwise_shift_left(num, 1),
        den,
        bigi.subtract(exp, one),
        one,
      )
  }
}

fn scale_down(num: BigInt, den: BigInt, exp: BigInt, one: BigInt) {
  let new_den = bigi.bitwise_shift_left(den, 1)
  case bigi.compare(num, new_den) {
    order.Lt -> #(bigi.bitwise_shift_right(den, 52), exp)
    _ -> scale_down(num, new_den, bigi.add(exp, one), one)
  }
}

fn decimal_to_float(sign: BigInt, num: BigInt, den: BigInt, exp: BigInt) {
  let quo = bigi.divide(num, den)
  let rem = bigi.subtract(num, bigi.multiply(quo, den))
  let one = bigi.from_int(1)

  let shifted_den = bigi.bitwise_shift_right(den, 1)
  let tmp = case bigi.compare(rem, shifted_den) {
    order.Gt -> bigi.add(quo, bigi.from_int(1))
    order.Lt -> quo
    order.Eq -> {
      case bigi.bitwise_and(quo, one) == one {
        True -> bigi.add(quo, one)
        False -> quo
      }
    }
  }

  let sign = case sign == bigi.from_int(-1) {
    True -> one
    False -> bigi.zero()
  }
  let p52 = bigi.from_int(power_of_2_to_52)
  let tmp = bigi.subtract(tmp, p52)
  let exp = case bigi.compare(tmp, p52) {
    order.Lt -> exp
    _ -> bigi.add(exp, one)
  }

  // Form float by scaling values to correct ranges and then converting to bytes

  let sign = bigi.bitwise_shift_left(sign, 63)

  use exp <- result.try(case
    bigi.compare(exp, bigi.from_int(-1022)),
    bigi.compare(exp, bigi.from_int(1023))
  {
    order.Lt, _ | _, order.Gt -> Error(OutOfRange)
    _, _ -> Ok(exp)
  })

  let exp = bigi.add(exp, bigi.from_int(1023)) |> bigi.bitwise_shift_left(52)

  use coef <- result.try(case
    bigi.compare(tmp, bigi.zero()),
    bigi.compare(tmp, bigi.subtract(bigi.from_int(power_of_2_to_52), one))
  {
    order.Lt, _ | _, order.Gt -> Error(OutOfRange)
    _, _ -> Ok(tmp)
  })

  let combined = sign |> bigi.bitwise_or(exp) |> bigi.bitwise_or(coef)
  let assert Ok(<<num:float>>) =
    bigi.to_bytes(combined, bigi.BigEndian, bigi.Unsigned, 8)

  Ok(num)
}

fn ratio(coef: BigInt, exp: BigInt) {
  case bigi.compare(exp, bigi.zero()) {
    order.Gt | order.Eq -> #(bigi.multiply(coef, pow10(exp)), bigi.from_int(1))
    order.Lt -> #(coef, pow10(bigi.negate(exp)))
  }
}

fn pow10(val: BigInt) {
  let assert Ok(val) = bigi.power(bigi.from_int(10), val)
  val
}
