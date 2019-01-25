import unittest, math, lmx

suite "spheres":
  test "a ray intersects a sphere at two points":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 2)
    check(xs[0].t =~ 4.0)
    check(xs[1].t =~ 6.0)

  test "a ray intersects a sphere at a tangent":
    let
      r = ray(point(0, 1, -5), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 2)
    checK(xs[0].t =~ 5.0)
    check(xs[1].t =~ 5.0)

  test "a ray misses a sphere":
    let
      r = ray(point(0, 2, -5), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 0)

  test "a ray originates inside a sphere":
    let
      r = ray(point(0, 0, 0), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 2)
    check(xs[0].t =~ -1.0)
    check(xs[1].t =~ 1.0)

  test "a sphere is behind a ray":
    let
      r = ray(point(0, 0, 5), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 2)
    check(xs[0].t =~ -6.0)
    check(xs[1].t =~ -4.0)

  test "intersect sets the object on the intersection":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      s = sphere()
      xs = intersect(s, r)
    check(len(xs) == 2)
    check(xs[0].obj == s)
    check(xs[1].obj == s)

  test "a sphere's default transformation":
    let s = sphere()
    check(s.transform =~ identity)

  test "changing the sphere's transformation":
    let t = translation(2, 3, 4)
    var s = sphere()
    s.transform = t
    check(s.transform == t)

  test "intersecting a scaled sphere with a ray":
    var s = sphere()
    s.transform = scaling(2, 2, 2)
    let 
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      xs = intersect(s, r)
    check(len(xs) == 2)
    check(xs[0].t =~ 3.0)
    check(xs[1].t =~ 7.0)

  test "intersecting a translated sphere with a ray":
    var s = sphere()
    s.transform = translation(5, 0, 0)
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      xs = intersect(s, r)
    check(len(xs) == 0)

  test "the normal on a sphere at a point on the x-axis":
    let 
      s = sphere()
      n = normal_at(s, point(1, 0, 0))
    check(n =~ vector(1, 0, 0))

  test "the normal on a sphere at a point on the y-axis":
    let 
      s = sphere()
      n = normal_at(s, point(0, 1, 0))
    check(n =~ vector(0, 1, 0))

  test "the normal on a sphere at a point on the z-axis":
    let 
      s = sphere()
      n = normal_at(s, point(0, 0, 1))
    check(n =~ vector(0, 0, 1))

  test "the normal on a sphere at a non-axial point":
    let 
      s = sphere()
      n = normal_at(s, point(sqrt(3.0) / 3, sqrt(3.0) / 3, sqrt(3.0) / 3))
    check(n =~ vector(sqrt(3.0) / 3, sqrt(3.0) / 3, sqrt(3.0) / 3))

  test "the normal is a normalized vector":
    let 
      s = sphere()
      n = normal_at(s, point(sqrt(3.0) / 3, sqrt(3.0) / 3, sqrt(3.0) / 3))
    check(n =~ normalize(n))

  test "computing the normal on a translated sphere":
    var s = sphere()
    s.transform = translation(0, 1, 0)
    let n = normal_at(s, point(0, 1.70711, -0.70711))
    check(n =~ vector(0, 0.70711, -0.70711))
  
  test "computing the nomral on a transformed sphere":
    var s = sphere()
    s.transform = scaling(1, 0.5, 1) * rotationZ(PI/5)
    let n = normal_at(s, point(0, sqrt(2.0) / 2, -sqrt(2.0) / 2))
    check(n =~ vector(0, 0.97014, -0.24254))

  test "a sphere has a default material":
    let 
      s = sphere()
      m = s.material
    check(m == material())
    
  test "a sphere may be assigned a material":
    var 
      s = sphere()
      m = material()
    m.ambient = 1
    s.material = m
    check(s.material == m)