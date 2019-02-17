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