import unittest, math, options
import lmx, utils

suite "triangles":
  test "creating triangle":
    let
      p1 = point(0, 1, 0)
      p2 = point(-1, 0, 0)
      p3 = point(1, 0, 0)
      t = newTriangle(p1, p2, p3)
    check(t.p1 == p1)
    check(t.p2 == p2)
    check(t.p3 == p3)
    check(t.e1 == vector(-1, -1, 0))
    check(t.e2 == vector(1, -1, 0))
    check(t.normal == vector(0, 0, -1))

  test "finding the normal on a triangle":
    let 
      t = newTriangle(
        point(0, 1, 0),
        point(-1, 0, 0),
        point(1, 0, 0))
      n1 = t.localNormalAt(point(0, 0.5, 0))
      n2 = t.localNormalAt(point(-0.5, 0.75, 0))
      n3 = t.localNormalAt(point(0.5, 0.25, 0))
    check(n1 =~ t.normal)
    check(n2 =~ t.normal)
    check(n3 =~ t.normal)

  test "intersecting a ray parallel to the triangle":
    let
      t = newTriangle(
        point(0, 1, 0),
        point(-1, 0, 0),
        point(1, 0, 0))
      r = initRay(point(0, -1, -2), vector(0, 1, 0))
      xs = t.localIntersect(r)
    check(len(xs) == 0)

  test "a ray misses the p1-p3 edge":
    let
      t = newTriangle(
        point(0, 1, 0),
        point(-1, 0, 0),
        point(1, 0, 0))
      r = initRay(point(1, 1, -2), vector(0, 0, 1))
      xs = t.localIntersect(r)
    check(len(xs) == 0)
  
  test "a ray misses the p1-p2 edge":
    let
      t = newTriangle(
        point(0, 1, 0),
        point(-1, 0, 0),
        point(1, 0, 0))
      r = initRay(point(-1, 1, -2), vector(0, 0, 1))
      xs = t.localIntersect(r)
    check(len(xs) == 0)
  
  test "a ray misses the p2-p3 edge":
    let
      t = newTriangle(
        point(0, 1, 0),
        point(-1, 0, 0),
        point(1, 0, 0))
      r = initRay(point(0, -1, -2), vector(0, 0, 1))
      xs = t.localIntersect(r)
    check(len(xs) == 0)

  test "a ray strikes a triangle":
    let
      t = newTriangle(
        point(0, 1, 0),
        point(-1, 0, 0),
        point(1, 0, 0))
      r = initRay(point(0, 0.5, -2), vector(0, 0, 1))
      xs = t.localIntersect(r)
    check(len(xs) == 1)
    checK(xs[0].t == 2)
  