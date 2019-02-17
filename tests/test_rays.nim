import unittest, math
import lmx, utils

suite "rays":
  test "creating a ray":
    let
      origin = point(1, 2, 3)
      direction = vector(4, 5, 6)
      r = ray(origin, direction)
    check(r.origin =~ origin)
    check(r.direction =~ direction)

  test "computing a point from a distance":
    let r = ray(point(2, 3, 4), vector(1, 0, 0))
    check(r.position(0) =~ point(2, 3, 4))
    check(r.position(1) =~ point(3, 3, 4))
    check(r.position(-1) =~ point(1, 3, 4))
    check(r.position(2.5) =~ point(4.5, 3, 4))

  test "a ray intersects a sphere at two points":
    let 
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      s = newSphere()
      xs = s.intersect(r)
    check(len(xs) == 2)
    check(xs[0].t =~ 4.0)
    check(xs[1].t =~ 6.0)
  
  test "a ray intersects a sphere at a tangent":
    let
      r = ray(point(0, 1, -5), vector(0, 0, 1))
      s = newSphere()
      xs = s.intersect(r)
    check(len(xs) == 2)
    check(xs[0].t =~ 5.0)
    check(xs[1].t =~ 5.0)

  test "a ray misses a sphere":
    let
      r = ray(point(0, 2, -5), vector(0, 0, 1))
      s = newSphere()
      xs = s.intersect(r)
    check(len(xs) == 0)

  test "a ray originates inside a sphere":
    let
      r = ray(point(0, 0, 0), vector(0, 0, 1))
      s = newSphere()
      xs = s.intersect(r)
    check(len(xs) == 2)
    check(xs[0].t =~ -1.0)
    check(xs[1].t =~ 1.0)

  test "a sphere is behind a ray":
    let
      r = ray(point(0, 0, 5), vector(0, 0, 1))
      s = newSphere()
      xs = s.intersect(r)
    check(len(xs) == 2)
    check(xs[0].t =~ -6.0)
    check(xs[1].t =~ -4.0)

  test "translating a ray":
    let
      r = ray(point(1, 2, 3), vector(0, 1, 0))
      m = translation(3, 4, 5)
      r2 = m * r
    check(r2.origin =~ point(4, 6, 8))
    check(r2.direction =~ vector(0, 1, 0))

  test "scaling a ray":
    let
      r = ray(point(1, 2, 3), vector(0, 1, 0))
      m = scaling(2, 3, 4)
      r2 = m * r
    check(r2.origin =~ point(2, 6, 12))
    check(r2.direction =~ vector(0, 3, 0))