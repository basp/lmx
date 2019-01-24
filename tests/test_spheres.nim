import unittest, math, lmx

suite "spheres":
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

  test "intersect sets the object on the intersection":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 2)
    check(xs[0].obj == s)
    check(xs[1].obj == s)

  test "a sphere's default transformation":
    let s = sphere()
    check(s.transform =~ identity)

  test "changing the sphere's transformation":
    let t = translation(2, 3, 4)
    var s = sphere()
    s.transform = t
    check(s.transform == t)

  test "intersecting a scaled sphere with a ray":
    var s = sphere()
    s.transform = scaling(2, 2, 2)
    let 
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      xs = intersect(s, r)
    check(len(xs) == 2)
    check(xs[0].t =~ 3.0)
    check(xs[1].t =~ 7.0)

  test "intersecting a translated sphere with a ray":
    var s = sphere()
    s.transform = translation(5, 0, 0)
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      xs = intersect(s, r)
    check(len(xs) == 0)
