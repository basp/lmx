import unittest, math
import lmx, utils

const
  black = color(0, 0, 0)
  white = color(1, 1, 1)

suite "patterns":
  test "creating a stripe pattern":
    let pat = newStripePattern(white, black)
    check(pat.a == white)
    check(pat.b == black)

  test "a stripe pattern is constant in y":
    let pat = newStripePattern(white, black)
    check(pat.colorAt(point(0, 0, 0)) == white)
    check(pat.colorAt(point(0, 1, 0)) == white)
    check(pat.colorAt(point(0, 2, 0)) == white)

  test "a stripe pattern is constant in z":
    let pat = newStripePattern(white, black)
    check(pat.colorAt(point(0, 0, 0)) == white)
    check(pat.colorAt(point(0, 0, 1)) == white)
    check(pat.colorAt(point(0, 0, 2)) == white)

  test "a stripe pattern alternates in x":
    let pat = newStripePattern(white, black)
    check(pat.colorAt(point(0, 0, 0)) == white)
    check(pat.colorAt(point(0.9, 0, 0)) == white)
    check(pat.colorAt(point(1, 0, 0)) == black)
    check(pat.colorAt(point(-0.1, 0, 0)) == black)
    check(pat.colorAt(point(-1, 0, 0)) == black)
    check(pat.colorAt(point(-1.1, 0, 0)) == white)

  test "stripes with an object transformation":
    let 
      obj = newSphere()
      pat = newStripePattern(white, black)
    obj.transform = scaling(2, 2, 2).initTransform()
    let c = pat.colorAt(obj, point(1.5, 0, 0))
    check(c =~ white)

  test "stripes with a pattern transformation":
    let
      obj = newSphere()
      pat = newStripePattern(white, black)
    pat.transform = scaling(2, 2, 2).initTransform()
    let c = pat.colorAt(obj, point(1.5, 0, 0))
  
  test "stripes with both an object and pattern transformation":
    let
      obj = newSphere()
      pat = newStripePattern(white, black)
    obj.transform = scaling(2, 2, 2).initTransform()
    pat.transform = translation(0.5, 0, 0).initTransform()
    let c = pat.colorAt(obj, point(2.5, 0, 0))
    check(c =~ white)

  test "a gradient linearly interpolates between colors":
    let pat = newGradientPattern(white, black)
    check(pat.colorAt(point(0, 0, 0)) =~ white)
    check(pat.colorAt(point(0.25, 0, 0)) =~ color(0.75, 0.75, 0.75))
    check(pat.colorAt(point(0.5, 0, 0)) =~ color(0.5, 0.5, 0.5))
    check(pat.colorAt(point(0.75, 0, 0)) =~ color(0.25, 0.25, 0.25))

  test "a righ should extend in both x and z":
    let pat = newRingPattern(white, black)
    check(pat.colorAt(point(0, 0, 0)) =~ white)
    check(pat.colorAt(point(1, 0, 0)) =~ black)
    check(pat.colorAt(point(0, 0, 1)) =~ black)
    check(pat.colorAt(point(0.708, 0, 0.708)) =~ black)