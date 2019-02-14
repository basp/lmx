import unittest
import lmx, utils

suite "colors":
  test "adding colors":
    let
      c1 = color(0.9, 0.6, 0.75)
      c2 = color(0.7, 0.1, 0.25)
    check(c1 + c2 =~ color(1.6, 0.7, 1.0))

  test "subtracting colors":
    let
      c1 = color(0.9, 0.6, 0.75)
      c2 = color(0.7, 0.1, 0.25)
    check(c1 - c2 =~ color(0.2, 0.5, 0.5))

  test "multiplying a color by a scalar":
    let c = color(0.2, 0.3, 0.4)
    check(c * 2 == color(0.4, 0.6, 0.8))

  test "the hadamard product of two colors":
    let
      c1 = color(1, 0.2, 0.4)
      c2 = color(0.9, 1, 0.1)
    check(c1 |*| c2 =~ color(0.9, 0.2, 0.04))