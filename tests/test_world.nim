import unittest, math
import lmx, utils

suite "world":
  test "creating a world":
    let w = newWorld()
    check(len(w.objects) == 0)
    check(len(w.lights) == 0)

  test "intersect a world with a ray":
    let 
      w = newDefaultWorld()
      r = initRay(point(0, 0, -5), vector(0, 0, 1))
      xs = w.intersect(r)
    check(len(xs) == 4)
    check(xs[0].t == 4)
    check(xs[1].t == 4.5)
    check(xs[2].t == 5.5)
    check(xs[3].t == 6)

  test "shading an intersection":
    let 
      w = newDefaultWorld()
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      shape = w.objects[0]
      i = intersection(4, shape)
      comps = i.precompute(r)
      c = w.shade(comps)
    check(c =~ color(0.38066, 0.47583, 0.2855))

  test "shading an intersection from the inside":
    let w = newDefaultWorld()
    w.lights = @[newPointLight(point(0, 0.25, 0), color(1, 1, 1))]
    let
      r = ray(point(0, 0, 0), vector(0, 0, 1))
      shape = w.objects[1]
      i = intersection(0.5, shape)
      comps = i.precompute(r)
      c = w.shade(comps)
    check(c =~ color(0.90498, 0.90498, 0.90498))

  test "the color when a ray misses":
    let
      w = newDefaultWorld()
      r = ray(point(0, 0, -5), vector(0, 1, 0))
      c = w.colorAt(r)
    check(c =~ color(0, 0, 0))

  test "the color when a ray hits":
    let
      w = newDefaultWorld()
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      c = w.colorAt(r)
    check(c =~ color(0.38066, 0.47583, 0.2855))
    
  test "the color with an intersection behind the ray":
    let
      r = ray(point(0, 0, 0.75), vector(0, 0, -1))
      w = newDefaultWorld()
      outer = w.objects[0]
      inner = w.objects[1]
    outer.material.ambient = 1
    inner.material.ambient = 1
    let c = w.colorAt(r)
    check(c =~ inner.material.color)

  test "there is no shadow when nothing is collinear with point and light":
    let
      w = newDefaultWorld()
      p = point(0, 10, 0)
    check(not w.shadowed(p, w.lights[0]))

  test "shadow when an object is between point and light":
    let
      w = newDefaultWorld()
      p = point(10, -10, 10)
    check(w.shadowed(p, w.lights[0]))

  test "there is no shadow when an object is behind the light":
    let
      w = newDefaultWorld()
      p = point(-20, 20, -20)
    check(not w.shadowed(p, w.lights[0]))

  test "there is no shadow when an object is behind the point":
    let
      w = newDefaultWorld()
      p = point(-2, 2, -2)
    check(not w.shadowed(p, w.lights[0]))

  test "shade an intersection in shadow":
    let
      w = newWorld()
      s1 = newSphere()
      s2 = newSphere()
      r = ray(point(0, 0, 5), vector(0, 0, 1))
      i = intersection(4, s2)
    s2.transform = translation(0, 0, 10).initTransform()
    w.lights = @[newPointLight(point(0, 0, -10), color(1, 1, 1))]
    w.objects.add(s1)
    w.objects.add(s2)
    let 
      comps = i.precompute(r)
      c = w.shade(comps)
    check(c =~ color(0.1, 0.1, 0.1))

