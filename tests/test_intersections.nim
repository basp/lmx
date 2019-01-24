import unittest, math, lmx

suite "intersections":
  test "an intersection encapsulates t and object":
    let 
      s = sphere()
      i = intersection(3.5, s)
    check(i.t == 3.5)
    check(i.obj == s)

  test "aggregating intersections":
    let
      s = sphere()
      i1 = intersection(1, s)
      i2 = intersection(2, s)
      xs = intersections(i1, i2)
    check(len(xs) == 2)
    check(xs[0].t == 1.0)
    check(xs[1].t == 2.0)