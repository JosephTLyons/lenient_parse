// Originally © Eric Meadows-Jönsson and contributors, translated from original
// source at https://github.com/ericmj/decimal/blob/045403e85a3eaaeec23f63cd884d785ca5cf5324/lib/decimal/context.ex

pub type Signal {
  InvalidOperation
  DivisionByZero
  Rounded
  Inexact
}

pub type Rounding {
  AwayFromZero
  TowardZero
  MidpointAwayFromZero
  MidpointNearestEven
  MidpointTowardZero
  TowardPositiveInfinity
  TowardNegativeInfinity
}
