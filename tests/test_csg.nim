import unittest, options
import lmx, utils

suite "CSG":
  test "creating a CSG object":
    let
      s1 = newSphere()
      s2 = newCube()
      c = newCsg(opUnion, s1, s2)
    check(c.op == opUnion)
    check(c.left == s1)
    check(c.right == s2)
    check(s1.parent.get() == c)
    check(s2.parent.get() == c)

  test "evaluating the fule for a CSG operation":
    let examples = @[
      (op: opUnion, lhit: true, inl: true, inr: true, result: false),
      (op: opUnion, lhit: true, inl: true, inr: false, result: true),
      (op: opUnion, lhit: true, inl: false, inr: true, result: false),
      (op: opUnion, lhit: true, inl: false, inr: false, result: true),
      (op: opUnion, lhit: false, inl: true, inr: true, result: false),
      (op: opUnion, lhit: false, inl: true, inr: false, result: false),
      (op: opUnion, lhit: false, inl: false, inr: true, result: true),
      (op: opUnion, lhit: false, inl: false, inr: false, result: true),
      (op: opIntersection, lhit: true, inl: true, inr: true, result: true),
      (op: opIntersection, lhit: true, inl: true, inr: false, result: false),
      (op: opIntersection, lhit: true, inl: false, inr: true, result: true),
      (op: opIntersection, lhit: true, inl: false, inr: false, result: false),
      (op: opIntersection, lhit: false, inl: true, inr: true, result: true),
      (op: opIntersection, lhit: false, inl: true, inr: false, result: true),
      (op: opIntersection, lhit: false, inl: false, inr: true, result: false),
      (op: opIntersection, lhit: false, inl: false, inr: false, result: false),
      (op: opDifference, lhit: true, inl: true, inr: true, result: false),
      (op: opDifference, lhit: true, inl: true, inr: false, result: true),
      (op: opDifference, lhit: true, inl: false, inr: true, result: false),
      (op: opDifference, lhit: true, inl: false, inr: false, result: true),
      (op: opDifference, lhit: false, inl: true, inr: true, result: true),
      (op: opDifference, lhit: false, inl: true, inr: false, result: true),
      (op: opDifference, lhit: false, inl: false, inr: true, result: false),
      (op: opDifference, lhit: false, inl: false, inr: false, result: false)]    
    for ex in examples:
      let result = ex.op.intersectionAllowed(ex.lhit, ex.inl, ex.inr)
      check(result == ex.result)

  test "filtering a list of intersections":
    let examples = @[
      (op: opUnion, x0: 0, x1: 3),
      (op: opIntersection, x0: 1, x1: 2),
      (op: opDifference, x0: 0, x1: 1)]   
    let
      s1 = newSphere()
      s2 = newCube()
    for ex in examples:
      let 
        c = newCsg(ex.op, s1, s2)
        xs = intersections(
          intersection(1, s1),
          intersection(2, s2),
          intersection(3, s1),
          intersection(4, s2))
        result = c.filterIntersections(xs)
      check(len(result) == 2)
      check(result[0] == xs[ex.x0])
      check(result[1] == xs[ex.x1])

  test "a ray missses a CSG object":
    let
      c = newCsg(opUnion, newSphere(), newCube())
      r = initRay(point(0, 2, -5), vector(0, 0, 1))
      xs = c.localIntersect(r)
    check(len(xs) == 0)

  test "a ray hits a CSG object":
    let
      s1 = newSphere()
      s2 = newSphere()
      c = newCsg(opUnion, s1, s2)
      r = initRay(point(0, 0, -5), vector(0, 0, 1))
    s2.transform = translation(0, 0, 0.5).initTransform()
    let xs = c.localIntersect(r)
    check(len(xs) == 2)
    check(xs[0].t == 4)
    check(xs[0].obj == s1)
    check(xs[1].t == 6.5)
    check(xs[1].obj == s2)
      