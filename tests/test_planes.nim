import unittest, math, lmx

suite "planes":
  test "the normal of a plane is constant everywhere":
    let 
      p = plane()
      n1 = local_normal_at(p, point(0, 0, 0))
      n2 = local_normal_at(p, point(10, 0, -10))
      n3 = local_normal_at(p, point(-5, 0, 150))
    check(n1 =~ vector(0, 1, 0))
    check(n2 =~ vector(0, 1, 0))
    check(n3 =~ vector(0, 1, 0))

  test "intersect with a ray parallel to the plane":
    let
      p = plane()
      r = ray(point(0, 10, 0), vector(0, 0, 1))
      xs = local_intersect(p, r)
    check(len(xs) == 0)

  test "intersect with a coplanar ray":
    let
      p = plane()
      r = ray(point(0, 0, 0), vector(0, 0, 1))
      xs = local_intersect(p, r)
    check(len(xs) == 0)

  test "a ray intersecting a plane from above":
    let
      p = plane()
      r = ray(point(0, 1, 0), vector(0, -1, 0))
      xs = local_intersect(p, r)
    check(len(xs) == 1)
    check(xs[0].t =~ 1)
    check(xs[0].obj == p)

    test "a ray intersecting a plane from below":
      let
        p = plane()
        r = ray(point(0, -1, 0), vector(0, 1, 0))
        xs = local_intersect(p, r)
      check(len(xs) == 1)
      check(xs[0].t =~ 1)
      check(xs[0].obj == p)
