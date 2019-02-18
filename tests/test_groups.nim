import unittest, math, options
import lmx, utils

suite "groups":
  test "adding a child to a group":
    let 
      g = newGroup()
      s = new TestShape
    g.add(s)
    check(len(g) > 0)
    check(s.parent == some(g))

  test "intersecting a ray with an empty group":
    let
      g = newGroup()
      r = initRay(point(0, 0, 0), vector(0, 0, 1))
      xs = g.localIntersect(r)
    check(len(xs) == 0)

  test "intersecting a ray with a non-empty group":
    let
      g = newGroup()
      s1 = newSphere()
      s2 = newSphere()
      s3 = newSphere()
      r = initRay(point(0, 0, -5), vector(0, 0, 1))
    s2.transform = translation(0, 0, -3).initTransform()
    s3.transform = translation(5, 0, 0).initTransform()
    g.add(s1)
    g.add(s2)
    g.add(s3)
    let xs = g.localIntersect(r)
    check(len(xs) == 4)
    check(xs[0].obj == s2)
    check(xs[1].obj == s2)
    check(xs[2].obj == s1)
    check(xs[3].obj == s1)

  test "intersecting a transformed group":
    let
      g = newGroup()
      s = newSphere()
      r = initRay(point(10, 0, -10), vector(0, 0, 1))
    g.transform = scaling(2, 2, 2).initTransform()
    s.transform = translation(5, 0, 0).initTransform()
    g.add(s)
    let xs = g.intersect(r)
    check(len(xs) == 2)

  
