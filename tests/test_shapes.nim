import unittest, math
import lmx, utils

type
  TestShape = ref object of Shape
    savedRay: Ray

method localIntersect(s: TestShape, r: Ray): seq[Intersection] =
  s.savedRay = r

method localNormalAt(s: TestShape, p: Point3): Vector3 =
  vector(p.x, p.y, p.z)

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
