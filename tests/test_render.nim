import unittest
import pkglmx/render, 
       pkglmx/geometry,
       utils

suite "colors":
  test "colors are (red, green, blue) tuples":
    let c = initColor(-0.5, 0.4, 1.7)
    check(c.r =~ -0.5)
    check(c.g =~ 0.4)
    check(c.b =~ 1.7)

  test "adding colors":
    let 
      c1 = initColor(0.9, 0.6, 0.75)
      c2 = initColor(0.7, 0.1, 0.25)
    check(c1 + c2 =~ initColor(1.6, 0.7, 1.0))

  test "subtracting colors":
    let 
      c1 = initColor(0.9, 0.6, 0.75)
      c2 = initColor(0.7, 0.1, 0.25)
    check(c1 - c2 =~ initColor(0.2, 0.5, 0.5))

  test "multiplying a color by a scalar":
    let c = initColor(0.2, 0.3, 0.4)
    check(c * 2 =~ initColor(0.4, 0.6, 0.8))

  test "multiplying colors":
    let c1 = initColor(1.0, 0.2, 0.4)
    let c2 = initColor(0.9, 1.0, 0.1)
    check(c1 |*| c2 =~ initColor(0.9, 0.2, 0.04))
    