import unittest, math, options
import lmx, utils

suite "cylinders":
  test "a ray misses a cylinder":
    let examples = @[
      (origin: point(1, 0, 0), direction: vector(0, 1, 0)),
      (origin: point(0, 0, 0), direction: vector(0, 1, 0)),
      (origin: point(0, 0, -5), direction: vector(1, 1, 1))
    ]
    let cyl = newCylinder()
    for ex in examples:
      let
        r = initRay(ex.origin, ex.direction)
        xs = cyl.localIntersect(r)
      check(len(xs) == 0)

  test "a ray strikes a cylinder":
    let examples = @[
      (origin: point(1, 0, -5), direction: vector(0, 0, 1), t0: 5.0, t1: 5.0),
      (origin: point(0, 0, -5), direction: vector(0, 0, 1), t0: 4.0, t1: 6.0),
      (origin: point(0.5, 0, -5), direction: vector(0.1, 1, 1), t0: 6.80798, t1: 7.08872)]
    let cyl = newCylinder()
    for ex in examples:
      let
        direction = ex.direction.normalize()
        r = initRay(ex.origin, direction)
        xs = cyl.localIntersect(r)
      check(len(xs) == 2)
      check(xs[0].t =~ ex.t0)
      check(xs[1].t =~ ex.t1)

  test "normal vector on a cylinder":
    let examples = @[
      (point: point(1, 0, 0), normal: vector(1, 0, 0)),
      (point: point(0, 5, -1), normal: vector(0, 0, -1)),
      (point: point(0, -2, 1), normal: vector(0, 0, 1)),
      (point: point(-1, 1, 0), normal: vector(-1, 0, 0))]
    let cyl = newCylinder()
    for ex in examples:
      let n = cyl.localNormalAt(ex.point)
      check(n =~ ex.normal)

  test "the minimum and maximum for a cylinder":
    let cyl = newCylinder()
    check(cyl.min == -Inf)
    check(cyl.max == Inf)

  test "intersecting a constrained cylinder":
    let examples = @[
      (i: 1, point: point(0, 1.5, 0), direction: vector(0.1, 1, 0), count: 0),
      (i: 2, point: point(0, 3, -5), direction: vector(0, 0, 1), count: 0),
      (i: 3, point: point(0, 0, -5), direction: vector(0, 0, 1), count: 0),
      (i: 4, point: point(0, 2, -5), direction: vector(0, 0, 1), count: 0),
      (i: 5, point: point(0, 1, -5), direction: vector(0, 0, 1), count: 0),
      (i: 6, point: point(0, 1.5, -2), direction: vector(0, 0, 1), count: 2)]
    let cyl = newCylinder()
    cyl.min = 1
    cyl.max = 2
    for ex in examples:
      let
        direction = ex.direction.normalize()
        r = initRay(ex.point, direction)
        xs = cyl.localIntersect(r)
      check(len(xs) == ex.count)

  test "the default closed value for a cylinder":
    let cyl = newCylinder()
    check(not cyl.closed)

  test "intersecting the caps of a closed cylinder":
    let examples = @[
      (point: point(0, 3, 0), direction: vector(0, -1, 0), count: 2),
      (point: point(0, 3, -2), direction: vector(0, -1, 2), count: 2),
      (point: point(0, 4, -2), direction: vector(0, -1, 1), count: 2),
      (point: point(0, 0, -2), direction: vector(0, 1, 2), count: 2),
      (point: point(0, -1, -2), direction: vector(0, 1, 1), count: 2)]
    let cyl = newCylinder()
    cyl.min = 1
    cyl.max = 2
    cyl.closed = true
    for ex in examples:
      let
        direction = ex.direction.normalize()
        r = initRay(ex.point, direction)
      let xs = cyl.localIntersect(r)
      check(len(xs) == ex.count)

  test "the normal vector on a cylinder's end caps":
    let examples = @[
      (point: point(0, 1, 0), normal: vector(0, -1, 0)),
      (point: point(0.5, 1, 0), normal: vector(0, -1, 0)),
      (point: point(0, 1, 0.5), normal: vector(0, -1, 0)),
      (point: point(0, 2, 0), normal: vector(0, 1, 0)),
      (point: point(0.5, 2, 0), normal: vector(0, 1, 0)),
      (point: point(0, 2, 0.5), normal: vector(0, 1, 0))]
    let cyl = newCylinder()
    cyl.min = 1
    cyl.max = 2
    cyl.closed = true
    for ex in examples:
      let n = cyl.localNormalAt(ex.point)
      check(n =~ ex.normal)
