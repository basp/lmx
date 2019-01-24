import unittest, math, options, lmx

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

  test "the hit, when all intersections have positive t":
    let
      s = sphere()
      i1 = intersection(1, s)
      i2 = intersection(2, s)
      xs = intersections(i1, i2)
      i = hit(xs)
    check(i.isSome())
    check(i.get() == i1)
    
  test "the hit, when some intersections have negative t":
    let
      s = sphere()
      i1 = intersection(-1, s)
      i2 = intersection(1, s)
      xs = intersections(i1, i2)
      i = hit(xs)
    check(i.isSome())
    check(i.get() == i2)

  test "the hit, when all intersections have negative t":
    let
      s = sphere()
      i1 = intersection(-2, s)
      i2 = intersection(-1, s)
      xs = intersections(i1, i2)
      i = hit(xs)
    check(i.isNone())
  
  test "the hit is always the lowest non-negative intersection":
    let
      s = sphere()
      i1 = intersection(5, s)
      i2 = intersection(7, s)
      i3 = intersection(-3, s)
      i4 = intersection(2, s)
      xs = intersections(i1, i2, i3, i4)
      i = hit(xs)
    check(i.isSome())
    check(i.get() == i4)
