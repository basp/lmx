import unittest, math, options
import lmx, utils

suite "cubes":
  test "a ray intersects a cube":
    let examples = @[
      (origin: point(5, 0.5, 0), direction: vector(-1, 0, 0), t1: 4.0, t2: 6.0),
      (origin: point(-5, 0.5, 0), direction: vector(1, 0, 0), t1: 4.0, t2: 6.0),
      (origin: point(0.5, 5, 0), direction: vector(0, -1, 0), t1: 4.0, t2: 6.0),
      (origin: point(0.5, -5, 0), direction: vector(0, 1, 0), t1: 4.0, t2: 6.0),
      (origin: point(0.5, 0, 5), direction: vector(0, 0, -1), t1: 4.0, t2: 6.0),
      (origin: point(0.5, 0, -5), direction: vector(0, 0, 1), t1: 4.0, t2: 6.0),
      (origin: point(0, 0.5, 0), direction: vector(0, 0, 1), t1: -1.0, t2: 1.0)]
    let c = newCube()
    for ex in examples:
      let 
        r = initRay(ex.origin, ex.direction)
        xs = c.localIntersect(r)
      check(len(xs) == 2)
      check(xs[0].t == ex.t1)
      check(xs[1].t == ex.t2)

  test "a ray misses a cube":
    let examples = @[
      (origin: point(-2, 0, 0), direction: vector(0.2673, 0.5345, 0.8018)),
      (origin: point(0, -2, 0), direction: vector(0.8018, 0.2673, 0.5345)),
      (origin: point(0, 0, -2), direction: vector(0.5345, 0.8018, 0.2673)),
      (origin: point(2, 0, 2), direction: vector(0, 0, -1)),
      (origin: point(0, 2, 2), direction: vector(0, -1, 0)),
      (origin: point(2, 2, 0), direction: vector(-1, 0, 0))]
    let c = newCube()
    for ex in examples:
      let
        r = initRay(ex.origin, ex.direction)
        xs = c.localIntersect(r)
      check(len(xs) == 0)

  test "the normal on the surface of a cube":
    let examples = @[
      (point: point(1, 0.5, -0.8), normal: vector(1, 0, 0)),
      (point: point(-1, -0.2, 0.9), normal: vector(-1, 0, 0)),
      (point: point(-0.4, 1, -0.1), normal: vector(0, 1, 0)),
      (point: point(0.3, -1, -0.7), normal: vector(0, -1, 0)),
      (point: point(-0.6, 0.3, 1), normal: vector(0, 0, 1)),
      (point: point(0.4, 0.4, -1), normal: vector(0, 0, -1)),
      (point: point(1, 1, 1), normal: vector(1, 0, 0)),
      (point: point(-1, -1, -1), normal: vector(-1, 0, 0))]
    let c = newCube()
    for ex in examples:
      let n = c.localNormalAt(ex.point)
      check(n =~ ex.normal)


    