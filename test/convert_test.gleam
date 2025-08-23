import lenient_parse/internal/base_constants.{base_10, base_16, base_2, base_8}
import lenient_parse/internal/convert.{digits_to_int_from_list}

pub fn digits_to_int_test() {
  assert digits_to_int_from_list([1, 2, 3], base_10) == 123
  assert digits_to_int_from_list([1, 0, 1], base_2) == 0b101
  assert digits_to_int_from_list([0o1, 0o2, 0o7], base_8) == 0o127
  assert digits_to_int_from_list([0xa, 0xb, 0xc, 0xd, 0xe, 0xf], base_16)
    == 0xabcdef
}
