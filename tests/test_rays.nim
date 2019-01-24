import unittest, math, lmx

suite "rays":
  test "creating and querying a ray":
    let
      origin = point(1, 2, 3)
      direction = vector(4, 5, 6)
      r = ray(origin, direction)
    check(r.origin =~ origin)
    check(r.direction =~ direction)

  test "computing a point from a distance":
    let
      r = ray(point(2, 3, 4), vector(1, 0, 0))
    check(position(r, 0) =~ point(2, 3, 4))
    check(position(r, 1) =~ point(3, 3, 4))
    check(position(r, -1) =~ point(1, 3, 4))
    check(position(r, 2.5) =~ point(4.5, 3, 4))

  test "a ray intersects a sphere at two points":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 2)
    check(xs[0].t =~ 4.0)
    check(xs[1].t =~ 6.0)

  test "a ray intersects a sphere at a tangent":
    let
      r = ray(point(0, 1, -5), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 2)
    checK(xs[0].t =~ 5.0)
    check(xs[1].t =~ 5.0)

  test "a ray misses a sphere":
    let
      r = ray(point(0, 2, -5), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 0)

  test "a ray originates inside a sphere":
    let
      r = ray(point(0, 0, 0), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 2)
    check(xs[0].t =~ -1.0)
    check(xs[1].t =~ 1.0)

  test "a sphere is behind a ray":
    let
      r = ray(point(0, 0, 5), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 2)
    check(xs[0].t =~ -6.0)
    check(xs[1].t =~ -4.0)