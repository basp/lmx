import unittest, math, options
import lmx, utils

suite "shapes":
  test "intersecting a scaled shape with a ray":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      s = new TestShape
    s.transform = scaling(2, 2, 2).initTransform()
    let xs = s.intersect(r)
    check(s.savedRay.origin =~ point(0, 0, -2.5))
    check(s.savedRay.direction =~ vector(0, 0, 0.5))

  test "intersecting a translated shape with a ray":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      s = new TestShape
    s.transform = translation(5, 0, 0).initTransform()
    let xs = s.intersect(r)
    check(s.savedRay.origin =~ point(-5, 0, -5))
    check(s.savedRay.direction =~ vector(0, 0, 1))

  test "computing the normal on a translated shape":
    let s = new TestShape
    s.transform = translation(0, 1, 0).initTransform()
    let n = s.normalAt(point(0, 1.70711, -0.70711))
    check(n =~ vector(0, 0.70711, -0.70711))

  test "computing the normal on a transformed shape":
    let s = new TestShape
    s.transform = initTransform(scaling(1, 0.5, 1) * rotationZ(PI / 5))
    let n = s.normalAt(point(0, sqrt2over2, -sqrt2over2))
    check(n =~ vector(0, 0.97014, -0.24254))

  test "a shape has a parent attribute":
    let s = new TestShape
    check(s.parent.isNone())

  test "converting a point from world to object space":
    let
      g1 = newGroup()
      g2 = newGroup()
      s = newSphere()
    g1.transform = rotationY(PI / 2).initTransform()
    g2.transform = scaling(2, 2, 2).initTransform()
    g1.add(g2)
    s.transform = translation(5, 0, 0).initTransform()
    g2.add(s)
    let p = s.worldToObject(point(-2, 0, -10))
    check(p =~ point(0, 0, -1))

  test "converting a normal from object to world space":
    let
      g1 = newGroup()
      g2 = newGroup()
      s = newSphere()
    g1.transform = rotationY(PI/2).initTransform()
    g2.transform = scaling(1, 2, 3).initTransform()
    g1.add(g2)
    s.transform = translation(5, 0, 0).initTransform()
    g2.add(s)
    let n = s.normalToWorld(vector(sqrt3over3, sqrt3over3, sqrt3over3))
    check(n =~ vector(0.285714, 0.4285714, -0.8571428))

  test "find the normal on a child object":
    let
      g1 = newGroup()
      g2 = newGroup()
      s = newSphere()
    g1.transform = rotationY(PI/2).initTransform()
    g2.transform = scaling(1, 2, 3).initTransform()
    s.transform = translation(5, 0, 0).initTransform()
    g1.add(g2)
    g2.add(s)
    let n = s.normalAt(point(1.7321, 1.1547, -5.5774))
    check(n =~ vector(0.285703, 0.428543, -0.857160))
