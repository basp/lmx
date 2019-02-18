import unittest, math, options
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
      c = w.shade(comps, 5)
    check(c =~ color(0.38066, 0.47583, 0.2855))

  test "shading an intersection from the inside":
    let w = newDefaultWorld()
    w.lights = @[newPointLight(point(0, 0.25, 0), color(1, 1, 1))]
    let
      r = ray(point(0, 0, 0), vector(0, 0, 1))
      shape = w.objects[1]
      i = intersection(0.5, shape)
      comps = i.precompute(r)
      c = w.shade(comps, 5)
    check(c =~ color(0.90498, 0.90498, 0.90498))

  test "the color when a ray misses":
    let
      w = newDefaultWorld()
      r = ray(point(0, 0, -5), vector(0, 1, 0))
      c = w.colorAt(r, 5)
    check(c =~ color(0, 0, 0))

  test "the color when a ray hits":
    let
      w = newDefaultWorld()
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      c = w.colorAt(r, 5)
    check(c =~ color(0.38066, 0.47583, 0.2855))
    
  test "the color with an intersection behind the ray":
    let
      r = ray(point(0, 0, 0.75), vector(0, 0, -1))
      w = newDefaultWorld()
      outer = w.objects[0]
      inner = w.objects[1]
    outer.material.ambient = 1
    inner.material.ambient = 1
    let c = w.colorAt(r, 5)
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
      c = w.shade(comps, 5)
    check(c =~ color(0.1, 0.1, 0.1))

  test "the reflected color for a non-reflective material":
    let
      w = newDefaultWorld()
      r = initRay(point(0, 0, 0), vector(0, 0, 1))
      shape = w.objects[1]
      i = initIntersection(1, shape)
    shape.material.ambient = 1
    let 
      comps = i.precompute(r)
      c = w.reflectedColor(comps, 5)
    check(c =~ color(0, 0, 0))

  test "the reflected color for a reflective material":
    let
      w = newDefaultWorld()
      shape = newPlane()
      r = initRay(point(0, 0, -3), vector(0, -sqrt2over2, sqrt2over2))
      i = initIntersection(sqrt(2.0), shape)
    shape.material.reflective = 0.5
    shape.transform = translation(0, -1, 0).initTransform()
    w.objects.add(shape)
    let
      comps = i.precompute(r)
      c = w.reflectedColor(comps, 5)
    check(c =~ color(0.190332, 0.237915, 0.14274915))

  test "shade with a reflective material":
    let
      w = newDefaultWorld()
      shape = newPlane()
      r = initRay(point(0, 0, -3), vector(0, -sqrt2over2, sqrt2over2))
      i = initIntersection(sqrt(2.0), shape)
    shape.material.reflective = 0.5
    shape.transform = translation(0, -1, 0).initTransform()
    w.objects.add(shape)
    let
      comps = i.precompute(r)
      c = w.shade(comps, 5)
    check(c =~ color(0.87675, 0.92434, 0.82917))

  test "mutually reflective surfaces":
    let
      w = newWorld()
      light = newPointLight(point(0, 0, 0), color(1, 1, 1))
      lower = newPlane()
      upper = newPlane()
    lower.material.reflective = 1
    lower.transform = translation(0, -1, 0).initTransform()
    upper.material.reflective = 1
    upper.transform = translation(0, 1, 0).initTransform()
    w.objects.add(lower)
    w.objects.add(upper)
    w.lights.add(light)
    let r = initRay(point(0, 0, 0), vector(0, 1, 0))
    discard w.colorAt(r, 5)
    check(true)

  test "the reflected color at the maximum recursive depth":
    let
      w = newDefaultWorld()
      shape = newPlane()
      r = initRay(point(0, 0, -3), vector(0, -sqrt2over2, sqrt2over2))
      i = initIntersection(sqrt(2.0), shape)
    shape.material.reflective = 0.5
    shape.transform = translation(0, -1, 0).initTransform()
    w.objects.add(shape)
    let
      comps = i.precompute(r)
      c = w.reflectedColor(comps, 0)
    check(c =~ color(0, 0, 0))

  test "the refracted color with an opaque surface":
    let 
      w = newDefaultWorld()
      shape = w.objects[0]
      r = initRay(point(0, 0, -5), vector(0, 0, 1))
      xs = intersections(
        initIntersection(4, shape),
        initIntersection(6, shape))
      comps = xs[0].precompute(r, xs)
      c = w.refractedColor(comps, 5)
    check(c =~ color(0, 0, 0))

  test "the refracted color at the maximum recursive depth":
    let
      w = newDefaultWorld()
      shape = w.objects[0]
      r = initRay(point(0, 0, -5), vector(0, 0, 1))
      xs = intersections(
        initIntersection(4, shape),
        initIntersection(6, shape))
    shape.material.transparency = 1.0
    shape.material.refractiveIndex = 1.5  
    let 
      comps = xs[0].precompute(r, xs)
      c = w.refractedColor(comps, 0)
    check(c =~ color(0, 0, 0))

  test "the refracted color under total internal refraction":
    let
      w = newDefaultWorld()
      shape = w.objects[0]
      r = initRay(point(0, 0, sqrt2over2), vector(0, 1, 0))
      xs = intersections(
        initIntersection(-sqrt2over2, shape),
        initIntersection(sqrt2over2, shape))
    shape.material.transparency = 1.0
    shape.material.refractiveIndex = 1.5
    let
      comps = xs[1].precompute(r, xs)
      c = w.refractedColor(comps, 5)
    check(c =~ color(0, 0, 0))

  test "the refracted color with a refracted ray":
    let
      w = newDefaultWorld()
      a = w.objects[0]
      b = w.objects[1]
      r = initRay(point(0, 0, 0.1), vector(0, 1, 0))
      xs = intersections(
        initIntersection(-0.9899, a),
        initIntersection(-0.4899, b),
        initIntersection(0.4899, b),
        initIntersection(0.9899, a))
    a.material.ambient = 1.0
    a.material.pattern = some(Pattern(newTestPattern()))
    b.material.transparency = 1.0
    b.material.refractiveIndex = 1.5
    let
      comps = xs[2].precompute(r, xs)
      c = w.refractedColor(comps, 5)
    check(c =~ color(0, 0.99887, 0.04721))

  test "shade with a transparent material":
    let
      w = newDefaultWorld()
      floor = newPlane()
      ball = newSphere()
      r = initRay(point(0, 0, -3), vector(0, -sqrt2over2, sqrt2over2))
      xs = intersections(
        initIntersection(sqrt(2.0), floor))
    floor.transform = translation(0, -1, 0).initTransform()
    floor.material.transparency = 0.5
    floor.material.refractiveIndex = 1.5
    ball.transform = translation(0, -3.5, -0.5).initTransform()
    ball.material.color = color(1, 0, 0)
    ball.material.ambient = 0.5
    w.objects.add(floor)
    w.objects.add(ball)
    let
      comps = xs[0].precompute(r, xs)
      c = w.shade(comps, 5)
    check(c =~ color(0.936425, 0.686425, 0.686425))