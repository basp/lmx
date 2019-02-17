import unittest, math
import lmx, utils

suite "planes":
  test "the normal of a plane is constant everywhere":
    let 
      p = newPlane()
      n1 = p.localNormalAt(point(0, 0, 0))
      n2 = p.localNormalAt(point(10, 0, -10))
      n3 = p.localNormalAt(point(-5, 0, 150))
    check(n1 =~ vector(0, 1, 0))
    check(n2 =~ vector(0, 1, 0))
    check(n3 =~ vector(0, 1, 0))

  test "intersect with a ray parallel to the plane":
    let
      p = newPlane()
      r = initRay(point(0, 10, 0), vector(0, 0, 1))
      xs = p.localIntersect(r)
    check(len(xs) == 0)

  test "intersect with a coplanar ray":
    let
      p = newPlane()
      r = initRay(point(0, 0, 0), vector(0, 0, 1))
      xs = p.localIntersect(r)
    check(len(xs) == 0)

  test "a ray intersecting a plane from above":
    let
      p = newPlane()
      r = initRay(point(0, 1, 0), vector(0, -1, 0))
      xs = p.localIntersect(r)
    check(len(xs) == 1)
    check(xs[0].t == 1)
    check(xs[0].obj == p)

  test "a ray intersecting a plane from above":
    let
      p = newPlane()
      r = ray(point(0, -1, 0), vector(0, 1, 0))
      xs = p.localIntersect(r)
    check(len(xs) == 1)
    check(xs[0].t == 1)
    check(xs[0].obj == p)
