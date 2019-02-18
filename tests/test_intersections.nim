import unittest, math, options
import lmx, utils

suite "intersections":
  test "creating intersections":
    let 
      s = newSphere()
      i = initIntersection(3.5, s)
    check(i.t =~ 3.5)
    check(i.obj == s)

  test "aggregating intersections":
    let
      s = newSphere()
      i1 = initIntersection(1, s)
      i2 = initIntersection(2, s)
      xs = intersections(i1, i2)
    check(len(xs) == 2)
    check(xs[0].t =~ 1)
    check(xs[1].t =~ 2)

  test "the hit, when all intersections have positive t":
    let
      s = newSphere()
      i1 = initIntersection(1, s)
      i2 = initIntersection(2, s)
      xs = intersections(i2, i1)
      i = xs.tryGetHit()
    check(i.isSome())
    check(i.get() == i1)

  test "the hit, when some intersections have negative t":
    let
      s = newSphere()
      i1 = initIntersection(-1, s)
      i2 = initIntersection(1, s)
      xs = intersections(i2, i1)
      i = xs.tryGetHit()
    check(i.isSome())
    check(i.get() == i2)

  test "the hit, when all intersections have negative t":
    let
      s = newSphere()
      i1 = initIntersection(-2, s)
      i2 = initIntersection(-1, s)
      xs = intersections(i2, i1)
      i = xs.tryGetHit()
    check(i.isNone())

  test "the hit is always the lowest non-negative intersection":
    let
      s = newSphere()
      i1 = initIntersection(5, s)
      i2 = initIntersection(7, s)
      i3 = initIntersection(-3, s)
      i4 = initIntersection(2, s)
      xs = intersections(i1, i2, i3, i4)
      i = xs.tryGetHit()
    check(i.isSome())
    check(i.get() == i4)

  test "precomputing the state of an intersection":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      shape = newSphere()
      i = intersection(4, shape)
      comps = i.precompute(r)
    check(comps.t == i.t)
    check(comps.obj == i.obj)
    check(comps.point =~ point(0, 0, -1))
    check(comps.eyev =~ vector(0, 0, -1))
    check(comps.normalv =~ vector(0, 0, -1))

  test "the hit, when an intersection occurs on the outside":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      shape = newSphere()
      i = intersection(4, shape)
      comps = i.precompute(r)
    check(not comps.inside)

  test "the hit, when an intersection occurs on the inside":
    let
      r = ray(point(0, 0, 0), vector(0, 0, 1))
      shape = newSphere()
      i = intersection(1, shape)
      comps = i.precompute(r)
    check(comps.point =~ point(0, 0, 1))
    check(comps.eyev =~ vector(0, 0, -1))
    check(comps.inside)
    check(comps.normalv =~ vector(0, 0, -1))

  test "the hit should offset the point":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      shape = newSphere()
      i = intersection(5, shape)
    shape.transform = translation(0, 0, 1).initTransform()
    let comps = i.precompute(r)
    check(comps.overPoint.z < -lmx.epsilon / 2)
    check(comps.point.z > comps.overPoint.z)

  test "precomputing the reflection vector":
    let
      shape = newPlane()
      r = initRay(point(0, 1, -1), vector(0, -sqrt2over2, sqrt2over2))
      i = initIntersection(sqrt(2.0), shape)
      comps = i.precompute(r)
    check(comps.reflectv =~ vector(0, sqrt2over2, sqrt2over2))

  test "finding n1 and n2 at various intersections":
    let 
      a = newGlassSphere()
      b = newGlassSphere()
      c = newGlassSphere()
      r = initRay(point(0, 0, -4), vector(0, 0, 1))
      xs = intersections(
        initIntersection(2, a),
        initIntersection(2.75, b),
        initIntersection(3.25, c),
        initIntersection(4.75, b),
        initIntersection(5.25, c),
        initIntersection(6, a))

    a.transform = scaling(2, 2, 2).initTransform()
    a.material.refractiveIndex = 1.5
    b.transform = translation(0, 0, -0.25).initTransform()
    b.material.refractiveIndex = 2.0
    c.transform = translation(0, 0, 0.25).initTransform()
    c.material.refractiveIndex = 2.5

    let examples = @[
      (index: 0, n1: 1.0, n2: 1.5),
      (index: 1, n1: 1.5, n2: 2.0),
      (index: 2, n1: 2.0, n2: 2.5),
      (index: 3, n1: 2.5, n2: 2.5),
      (index: 4, n1: 2.5, n2: 1.5),
      (index: 5, n1: 1.5, n2: 1.0)]

    for ex in examples:
      let comps = xs[ex.index].precompute(r, xs)
      check(comps.n1 == ex.n1)
      check(comps.n2 == ex.n2)

  test "the under point is offset below the surface":
    let
      r = initRay(point(0, 0, -5), vector(0, 0, 1))
      shape = newGlassSphere()
      i = initIntersection(5, shape)
      xs = intersections(i)
    shape.transform = translation(0, 0, 1).initTransform()
    let comps = i.precompute(r, xs)
    check(comps.underPoint.z > epsilon / 2)
    check(comps.point.z < comps.underPoint.z)