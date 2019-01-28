import unittest, math, options, pkglmx/core

type
  TestShape = ref object of Shape

method local_normal_at(s: TestShape, p: Vec4): Vec4 =
  vector(p.x, p.y, p.z)

suite "shapes":
  test "the default transformation":
    let s = TestShape()
    init_shape(s)
    check(s.transform =~ identity)

  test "assigning a transformation":
    let s = TestShape()
    s.transform = translation(2, 3, 4)
    check(s.transform =~ translation(2, 3, 4))

  test "the default material":
    let s = TestShape()
    init_shape(s)
    check(s.material == material())

  test "assigning a material":
    var 
      s = TestShape()
      m = material()
    m.ambient = 1
    s.material = m
    check(s.material == m)

  test "intersecting a scaled shape with a ray":
    let r =ray(point(0, 0, -5), vector(0, 0, 1))
    var s = TestShape()
    init_shape(s)
    s.transform = scaling(2, 2, 2)
    let xs = intersect(s, r)
    check(s.saved_ray.origin =~ point(0, 0, -2.5))
    check(s.saved_ray.direction =~ vector(0, 0, 0.5))

  test "intersecting a translated shape with a ray":
    let r = ray(point(0, 0, -5), vector(0, 0, 1))
    var s = TestShape()
    init_shape(s)
    s.transform = translation(5, 0, 0)
    let xs = intersect(s, r)
    check(s.saved_ray.origin =~ point(-5, 0, -5))
    check(s.saved_ray.direction =~ vector(0, 0, 1))

  test "computing the normal on a translated shape":
    var s = TestShape()
    init_shape(s)
    s.transform = translation(0, 1, 0)
    let n = normal_at(s, point(0, 1.70711, -0.70711))
    check(n =~ vector(0, 0.70711, -0.70711))

  test "computing the normal on a transformed shape":
    var s = TestShape()
    init_shape(s)
    let m = scaling(1, 0.5, 1) * rotation_z(PI/5.0)
    s.transform = m
    let n = normal_at(s, point(0, sqrt(2.0)/2, -sqrt(2.0)/2))
    check(n =~ vector(0, 0.97014, -0.24254))
    
    