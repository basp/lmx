import unittest, math, pkglmx/core

type TestPattern = ref object of Pattern

method pattern_at(pat: TestPattern, p: Vec4): Color =
  color(p.x, p.y, p.z)

suite "patterns":
  setup:
    let 
      black = color(0, 0, 0)
      white = color(1, 1, 1)

  test "creating a stripe pattern":
    let
      pattern = stripe_pattern(white, black)
    check(pattern.a =~ white)
    check(pattern.b =~ black)

  test "a stripe pattern is constant in y":
    let
      pattern = stripe_pattern(white, black)
    check(stripe_at(pattern, point(0, 0, 0)) =~ white)
    check(stripe_at(pattern, point(0, 1, 0)) =~ white)
    check(stripe_at(pattern, point(0, 2, 0)) =~ white)

  test "a stripe pattern is constant in z":
    let
      pattern = stripe_pattern(white, black)
    check(stripe_at(pattern, point(0, 0, 0)) =~ white)
    check(stripe_at(pattern, point(0, 0, 1)) =~ white)
    check(stripe_at(pattern, point(0, 0, 2)) =~ white)

  test "a stripe pattern alternates in x":
    let
      pattern = stripe_pattern(white, black)
    check(stripe_at(pattern, point(0, 0, 0)) =~ white)
    check(stripe_at(pattern, point(0.9, 0, 0)) =~ white)
    check(stripe_at(pattern, point(1, 0, 0)) =~ black)
    check(stripe_at(pattern, point(-0.1, 0, 0)) =~ black)
    check(stripe_at(pattern, point(-1, 0, 0)) =~ black)
    check(stripe_at(pattern, point(-1.1, 0, 0)) =~ white)

  test "stripes with an object transformation":
    var obj = sphere()
    let pat = stripe_pattern(white, black)
    obj.transform = scaling(2, 2, 2)
    let c = pattern_at_shape(pat, obj, point(1.5, 0, 0))
    check(c =~ white)

  test "stripes with a pattern transformation":
    let obj = sphere()
    var pat = stripe_pattern(white, black)
    pat.transform = scaling(2, 2, 2)
    let c = pattern_at_shape(pat, obj, point(1.5, 0, 0))
    check(c =~ white)

  test "stripes with both an object and pattern transformation":
    var
      obj = sphere()
      pat = stripe_pattern(white, black)
    pat.transform = translation(0.5, 0, 0)
    obj.transform = scaling(2, 2, 2)
    let c = pattern_at_shape(pat, obj, point(2.5, 0, 0))
    check(c =~ white)

  test "the default pattern transformation":
    var pat = TestPattern()
    init_pattern(pat)
    check(pat.transform =~ identity)

  test "assigning a transformation":
    var pat = TestPattern()
    init_pattern(pat)
    pat.transform = translation(1, 2, 3)
    check(pat.transform =~ translation(1, 2, 3))

  test "a pattern with an object transformation":
    var 
      shape = sphere()
      pat = TestPattern()
    shape.transform = scaling(2, 2, 2)
    init_pattern(pat)
    let c = pattern_at_shape(pat, shape, point(2, 3, 4))
    check(c =~ color(1, 1.5, 2))
    
  test "a pattern with a pattern transformation":
    var
      shape = sphere()
      pat = TestPattern()
    init_pattern(pat)
    pat.transform = scaling(2, 2, 2)
    let c = pattern_at_shape(pat, shape, point(2, 3, 4))
    check(c =~ color(1, 1.5, 2))

  test "a pattern with both an object and a pattern transformation":
    var
      shape = sphere()
      pat = TestPattern()
    init_pattern(pat)
    shape.transform = scaling(2, 2, 2)
    pat.transform = translation(0.5, 1, 1.5)
    let c = pattern_at_shape(pat, shape, point(2.5, 3, 3.5))
    check(c =~ color(0.75, 0.5, 0.25))

  test "a gradient linearly interpolates between colors":
    let pat = gradient_pattern(white, black)
    check(pattern_at(pat, point(0, 0, 0)) =~ white)
    check(pattern_at(pat, point(0.25, 0, 0)) =~ color(0.75, 0.75, 0.75))
    check(pattern_at(pat, point(0.5, 0, 0)) =~ color(0.5, 0.5, 0.5))
    check(pattern_at(pat, point(0.75, 0, 0)) =~ color(0.25, 0.25, 0.25))

  test "a ring should extend in both x and z":
    let pat = ring_pattern(white, black)
    check(pattern_at(pat, point(0, 0, 0)) =~ white)
    check(pattern_at(pat, point(1, 0, 0)) =~ black)
    check(pattern_at(pat, point(0, 0, 1)) =~ black)
    check(pattern_at(pat, point(0.708, 0, 0.708)) =~ black)

  test "checkers should repeat in x":
    let pat = checkers_pattern(white, black)
    check(pattern_at(pat, point(0, 0, 0)) =~ white)
    check(pattern_at(pat, point(0.99, 0, 0)) =~ white)
    check(pattern_at(pat, point(1.01, 0, 0)) =~ black)

  test "checkers should repeat in y":    
    let pat = checkers_pattern(white, black)
    check(pattern_at(pat, point(0, 0, 0)) =~ white)
    check(pattern_at(pat, point(0, 0.99, 0)) =~ white)
    check(pattern_at(pat, point(0, 1.01, 0)) =~ black)

  test "checkers should repeat in z":    
    let pat = checkers_pattern(white, black)
    check(pattern_at(pat, point(0, 0, 0)) =~ white)
    check(pattern_at(pat, point(0, 0, 0.99)) =~ white)
    check(pattern_at(pat, point(0, 0, 1.01)) =~ black)
