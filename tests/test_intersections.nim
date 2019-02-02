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

  test "precomputing the state of an intersection":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      shape = sphere()
      i = intersection(4, shape)
      comps = prepare_computations(i, r, @[i])
    check(comps.t == i.t)
    check(comps.obj == i.obj)
    check(comps.point == point(0, 0, -1))
    check(comps.eyev == vector(0, 0, -1))
    check(comps.normalv == vector(0, 0, -1))

  test "the hit, when an intersection occurs on the outside":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      shape = sphere()
      i = intersection(4, shape)
      comps = prepare_computations(i, r, @[i])
    check(not comps.inside)

  test "the hit, when an intersection occurs on the inside":
    let
      r = ray(point(0, 0, 0), vector(0, 0, 1))
      shape = sphere()
      i = intersection(1, shape)
      comps = prepare_computations(i, r, @[i])
    check(comps.point =~ point(0, 0, 1))
    check(comps.eyev =~ vector(0, 0, -1))
    check(comps.inside)
    # normal would have been (0, 0, 1) but is inverted
    check(comps.normalv =~ vector(0, 0, -1))

  test "the hit should offset the point":
    var 
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      shape = sphere()
    shape.transform = translation(0, 0, 1)
    let 
      i = intersection(5, shape)
      comps = prepare_computations(i, r, @[i])
    check(comps.over_point.z < (-epsilon/2.0))
    check(comps.point.z > comps.over_point.z)
    
  test "precomputing the reflection vector":
    let 
      shape = plane()
      r = ray(point(0, 1, -1), vector(0, -sqrt(2.0)/2.0, sqrt(2.0)/2.0))
      i = intersection(sqrt(2.0), shape)
      comps = prepare_computations(i, r, @[i])
    check(comps.reflectv == vector(0, sqrt(2.0)/2, sqrt(2.0)/2))

  test "the under point is offset below the surface":
    var shape = glass_sphere()
    let 
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      i = intersection(5, shape)
      xs = intersections(i)
    shape.transform = translation(0, 0, 1)
    let comps = prepare_computations(i, r, xs)
    check(comps.under_point.z > epsilon/2)
    check(comps.point.z < comps.under_point.z)
    