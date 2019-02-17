import unittest, math
import lmx, utils

const 
  piOver2 = PI / 2
  piOver4 = PI / 4
  sqrt2over2 = sqrt(2.0) / 2

suite "transformations":
  test "multiplying by a translation matrix":
    let 
      t = translation(5, -3, 2)
      p = point(-3, 4, 5)
    check(t * p =~ point(2, 1, 7))

  test "multiplying by the inverse of a translation matrix":
    let
      t = translation(5, -3, 2)
      inv = t.inverse()
      p = point(-3, 4, 5)
    check(inv * p =~ point(-8, 7, 3))

  test "translation does not affect vectors":
    let
      t = translation(5, -3, 2)
      v = vector(-3, 4, 5)
    check(t * v =~ v)

  test "a scaling matrix applied to a point":
    let
      t = scaling(2, 3, 4)
      p = point(-4, 6, 8)
    check(t * p =~ point(-8, 18, 32))

  test "a scaling matrix applied to a vector":
    let
      t = scaling(2, 3, 4)
      v = vector(-4, 6, 8)
    check(t * v =~ vector(-8, 18, 32))

  test "multiplying by the inverse of a scaling matrix":
    let
      t = scaling(2, 3, 4)
      inv = t.inverse()
      v = vector(-4, 6, 8)
    check(inv * v =~ vector(-2, 2, 2))

  test "reflection is scaling with a negative value":
    let
      t = scaling(-1, 1, 1)
      v = vector(-4, 6, 8)
    check(t * v =~ vector(4, 6, 8))

  test "rotating a point around the x-axis":
    let
      p = point(0, 1, 0)
      halfQuarter = rotationX(piOver4)
      fullQuarter = rotationX(piOver2)
    check(halfQuarter * p =~ point(0, sqrt2over2, sqrt2over2))
    check(fullQuarter * p =~ point(0, 0, 1))

  test "the inverse of an x-rotation rotates in the opposite direction":
    let
      p = point(0, 1, 0)
      halfQuarter = rotationX(piOver4)
      inv = halfQuarter.inverse()
    check(inv * p =~ point(0, sqrt2over2, -sqrt2over2))

  test "rotating a point around the y-axis":
    let
      p = point(0, 0, 1)
      halfQuarter = rotationY(piOver4)
      fullQuarter = rotationY(piOver2)
    check(halfQuarter * p =~ point(sqrt2over2, 0, sqrt2over2))
    check(fullQuarter * p =~ point(1, 0, 0))

  test "rotating a point around the z-axis":
    let
      p = point(0, 1, 0)
      halfQuarter = rotationZ(piOver4)
      fullQuarter = rotationZ(piOver2)
    check(halfQuarter * p =~ point(-sqrt2over2, sqrt2over2, 0))
    check(fullQuarter * p =~ point(-1, 0, 0))

  test "shearing moves x in proportion to y":
    let
      t = shearing(1, 0, 0, 0, 0, 0)
      p = point(2, 3, 4)
    check(t * p =~ point(5, 3, 4))

  test "shearing moves x in proportion to z":
    let
      t = shearing(0, 1, 0, 0, 0, 0)
      p = point(2, 3, 4)
    check(t * p =~ point(6, 3, 4))

  test "shearing moves y in proportion to x":
    let
      t = shearing(0, 0, 1, 0, 0, 0)
      p = point(2, 3, 4)
    check(t * p =~ point(2, 5, 4))

  test "shearing moves y in proportion to z":
    let
      t = shearing(0, 0, 0, 1, 0, 0)
      p = point(2, 3, 4)
    check(t * p =~ point(2, 7, 4))

  test "shearing moves z in proportion to x":
    let
      t = shearing(0, 0, 0, 0, 1, 0)
      p = point(2, 3, 4)
    check(t * p =~ point(2, 3, 6))

  test "shearing moves z in proportion to y":
    let
      t = shearing(0, 0, 0, 0, 0, 1)
      p = point(2, 3, 4)
    check(t * p =~ point(2, 3, 7))

  test "individual transformations are applied in sequence":
    let
      a = rotationX(piOver2)
      b = scaling(5, 5, 5)
      c = translation(10, 5, 7)
      p1 = point(1, 0, 1)
      p2 = a * p1
      p3 = b * p2
      p4 = c * p3
    check(p2 =~ point(1, -1, 0))
    check(p3 =~ point(5, -5, 0))
    check(p4 =~ point(15, 0, 7))

  test "chained transformations must be applied in reverse order":
    let
      a = rotationX(piOver2)
      b = scaling(5, 5, 5)
      c = translation(10, 5, 7)
      p = point(1, 0, 1)
      t = c * b * a
    check(t * p =~ point(15, 0, 7))

  test "fluent transformations are applied in sequence":
    let
      t = identityMatrix.
        rotateX(piOver2).
        scale(5, 5, 5).
        translate(10, 5, 7)
      p = point(1, 0, 1)
    check(t * p =~ point(15, 0, 7))
  
  test "the transformation matrix for the default orientation":
    let
      `from` = point(0, 0, 0)
      to = point(0, 0, -1)
      up = vector(0, 1, 0)
      t = view(`from`, to, up)
    check(t =~ identityMatrix)

  test "a view transformation looking in positive z direction":
    let
      `from` = point(0, 0, 0)
      to = point(0, 0, 1)
      up = vector(0, 1, 0)
      t = view(`from`, to, up)
    check(t =~ scaling(-1, 1, -1))

  test "the view transformation moves the world":
    let
      `from` = point(0, 0, 8)
      to = point(0, 0, 0)
      up = vector(0, 1, 0)
      t = view(`from`, to, up)
    check(t =~ translation(0, 0, -8))

  test "an arbitrary view transformation":
    let
      `from` = point(1, 3, 2)
      to = point(4, -2, 8)
      up = vector(1, 1, 0)
      t = view(`from`, to, up)
    check(t =~ matrix(-0.50709, 0.50709, 0.676120, -2.36643,
                      0.767720, 0.60609, 0.121220, -2.82843,
                      -0.35857, 0.59761, -0.71714, 0.000000,
                      0.000000, 0.00000, 0.000000, 1.000000))