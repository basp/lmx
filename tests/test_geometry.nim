import unittest, math
import lmx, utils

suite "geometry":
  test "create points using sugar":
    let p = point(0.1, 0.2, 0.3)
    check(p.x == 0.1)
    check(p.y == 0.2)
    check(p.z == 0.3)

  test "create vectors using sugar":
    let v = vector(1, 2, 3)
    check(v.x == 1.0)
    check(v.y == 2.0)
    check(v.z == 3.0)

  test "addition of a point and a vector":
    let 
      p = point(3, -2, 5)
      v = vector(-2, 3, 1)
    check(p + v == point(1, 1, 6))

  test "subtracting two points":
    let
      a = point(3, 2, 1)
      b = point(5, 6, 7)
    check(a - b == vector(-2, -4, -6))

  test "subtracting a vector from a point":
    let
      p = point(3, 2, 1)
      v = vector(5, 6, 7)
    check(p - v == point(-2, -4, -6))

  test "subtracting two vectors":
    let
      a = vector(3, 2, 1)
      b = vector(5, 6, 7)
    check(a - b == vector(-2, -4, -6))

  test "subtracting a vector from the zero vector":
    let
      v = vector(3, 2, 1)
      v0 = vector(0, 0, 0)
    check(v0 - v == vector(-3, -2, -1))

  test "negating a vector":
    let v = vector(1, -2, 3)
    check(-v == vector(-1, 2, -3))

  test "multiplying a vector by a scalar":
    let v = vector(1, -2, 3)
    check(v * 3.5 == vector(3.5, -7, 10.5))

  test "dividing a vector by a scalar":
    let v = vector(1, -2, 3)
    check(v / 2 == vector(0.5, -1, 1.5))

  test "computing the magnitude of vector(1, 0, 0)":
    let v = vector(1, 0, 0)
    check(v.magnitude() == 1)

  test "computing the magnitude of vector(0, 1, 0)":
    let v = vector(0, 1, 0)
    check(v.magnitude() == 1)

  test "computing the magnitude of vector(0, 0, 1)":
    let v = vector(0, 0, 1)
    check(v.magnitude() == 1)

  test "computing the magnitude of vector(1, 2, 3)":
    let v = vector(1, 2, 3)
    check(v.magnitude() =~ sqrt(14.0))

  test "computing the magnitude of vector(-1, -2, -3)":
    let v = vector(-1, -2, -3)
    check(v.magnitude() =~ sqrt(14.0))

  test "normalizing vector(4, 0, 0) gives (1, 0, 0)":
    let v = vector(4, 0, 0)
    check(v.normalize() == vector(1, 0, 0))

  test "normalizing vector(1, 2, 3)":
    let v = vector(1, 2, 3)
    check(v.normalize() =~ vector(0.26726, 0.53452, 0.80178))

  test "the magnitude of a normalized vector":
    let v = vector(1, 2, 3)
    check(v.normalize().magnitude() =~ 1)

  test "the dot product of two vectors":
    let
      a = vector(1, 2, 3)
      b = vector(2, 3, 4)
    check(a.dot(b) == 20)

  test "the cross product of two vectors":
    let
      a = vector(1, 2, 3)
      b = vector(2, 3, 4)
    check(a.cross(b) == vector(-1, 2, -1))
    check(b.cross(a) == vector(1, -2, 1))