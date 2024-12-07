import gleam/int

const safe_integer = 9_007_199_254_740_991

pub fn min_safe_integer() -> Int {
  -safe_integer
}

pub fn min_safe_integer_string() -> String {
  min_safe_integer() |> int.to_string
}

pub fn min_safe_integer_minus_1() -> Int {
  min_safe_integer() - 1
}

pub fn min_safe_integer_minus_1_string() -> String {
  min_safe_integer_minus_1() |> int.to_string
}

pub fn max_safe_integer() -> Int {
  safe_integer
}

pub fn max_safe_integer_string() -> String {
  max_safe_integer() |> int.to_string
}

pub fn max_safe_integer_plus_1() -> Int {
  safe_integer + 1
}

pub fn max_safe_integer_plus_1_string() -> String {
  max_safe_integer_plus_1() |> int.to_string
}
