import gleam/deque
import lenient_parse/internal/scale

pub fn scale_deques_test() {
  let a = deque.from_list([1, 2, 3])
  let b = deque.from_list([4, 5, 6])

  let #(a, b) = scale.deques(a, b, 1)

  assert deque.to_list(a) == [1, 2, 3, 4]
  assert deque.to_list(b) == [5, 6]

  let #(a, b) = scale.deques(a, b, 1)

  assert deque.to_list(a) == [1, 2, 3, 4, 5]
  assert deque.to_list(b) == [6]

  let #(a, b) = scale.deques(a, b, 1)

  assert deque.to_list(a) == [1, 2, 3, 4, 5, 6]
  assert deque.to_list(b) == []

  let #(a, b) = scale.deques(a, b, 1)

  assert deque.to_list(a) == [1, 2, 3, 4, 5, 6, 0]
  assert deque.to_list(b) == []

  let #(a, b) = scale.deques(a, b, -3)

  assert deque.to_list(a) == [1, 2, 3, 4]
  assert deque.to_list(b) == [5, 6, 0]

  let #(a, b) = scale.deques(a, b, -4)

  assert deque.to_list(a) == []
  assert deque.to_list(b) == [1, 2, 3, 4, 5, 6, 0]

  let #(a, b) = scale.deques(a, b, -3)

  assert deque.to_list(a) == []
  assert deque.to_list(b) == [0, 0, 0, 1, 2, 3, 4, 5, 6, 0]
}
