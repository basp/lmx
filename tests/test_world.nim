import unittest, sequtils, options, lmx

suite "world":
  test "creating a world":
    let w = world()
    check(len(w.objects) == 0)
    check(len(w.lights) == 0)

  test "the default world":
    let 
      w = default_world()
      light = point_light(point(-10, 10, -10), color(1, 1, 1))
    var
      s1 = sphere()
      s2 = sphere()
    s1.material.color = color(0.8, 1.0, 0.6)
    s1.material.diffuse = 0.7
    s1.material.specular = 0.2
    s2.transform = scaling(0.5, 0.5, 0.5)
    check(len(w.lights) > 0)
    check(w.lights[0] == light)
    check(count(w.objects, s1) == 1)
    check(count(w.objects, s2) == 1)

  test "intersect a world with a ray":
    let
      w = default_world()
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      xs = intersect_world(w, r)
    check(xs[0].t == 4.0)
    check(xs[1].t == 4.5)
    check(xs[2].t == 5.5)
    check(xs[3].t == 6.0)

  test "shading an intersection":
    let
      w = default_world()
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      shape = w.objects[0]
      i = intersection(4, shape)
      comps = prepare_computations(i, r)
      c = shade_hit(w, comps)
    check(c =~ color(0.38066, 0.47583, 0.2855))

  test "shading an intersection from the inside":
    var
      w = default_world()
      r = ray(point(0, 0, 0), vector(0, 0, 1))
      shape = w.objects[1]
      i = intersection(0.5, shape)
    w.lights = @[point_light(point(0, 0.25, 0), color(1, 1, 1))]
    let
      comps = prepare_computations(i, r)
      c = shade_hit(w, comps)
    checK(c =~ color(0.90498, 0.90498, 0.90498))

