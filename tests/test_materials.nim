import unittest, math, options, lmx

suite "materials":
  setup:
    var 
      m = material()
      position = point(0, 0, 0)
      s = sphere()

  test "the default material":
    check(m.color == color(1, 1, 1))
    check(m.ambient == 0.1)
    check(m.diffuse == 0.9)
    check(m.specular == 0.9)
    check(m.shininess == 200.0)
  
  test "lighting with the eye between the light and the surface":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = point_light(point(0, 0, -10), color(1, 1, 1))
      result = lighting(m, s, light, position, eyev, normalv)
    check(result =~ color(1.9, 1.9, 1.9))

  test "lighting with the eye between light and surface, eye offset 45 degrees":
    let
      eyev = vector(0, sqrt(2.0) / 2, -sqrt(2.0) / 2)
      normalv = vector(0, 0, -1)
      light = point_light(point(0, 0, -10), color(1, 1, 1))
      result = lighting(m, s, light, position, eyev, normalv)
    check(result =~ color(1.0, 1.0, 1.0))

  test "lighting with eye opposite surface, light offset 45 degrees":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = point_light(point(0, 10, -10), color(1, 1, 1))
      result = lighting(m, s, light, position, eyev, normalv)
    check(result =~ color(0.7364, 0.7364, 0.7364))
    
  test "lighting with eye in the path of the reflection vector":
    let
      eyev = vector(0, -sqrt(2.0) / 2.0, -sqrt(2.0) / 2.0)
      normalv = vector(0, 0, -1)
      light = point_light(point(0, 10, -10), color(1, 1, 1))
      result = lighting(m, s, light, position, eyev, normalv)
    check(result =~ color(1.6364, 1.6364, 1.6364))

  test "lighting with the light behind the surface":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = point_light(point(0, 0, 10), color(1, 1, 1))
      result = lighting(m, s, light, position, eyev, normalv)
    check(result =~ color(0.1, 0.1, 0.1))
    
  test "lighting with the surface in shadow":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, 1)
      light = point_light(point(0, 0, -10), color(1, 1, 1))
      in_shadow = true
      result = lighting(m, s, light, position, eyev, normalv, in_shadow)
    check(result =~ color(0.1, 0.1, 0.1))

  test "lighting with a pattern applied":
    let pat = stripe_pattern(color(1, 1, 1), color(0, 0, 0))
    m.pattern = some(Pattern(pat))
    m.ambient = 1
    m.diffuse = 0
    m.specular = 0
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = point_light(point(0, 0, -10), color(1, 1, 1))
      c1 = lighting(m, s, light, point(0.9, 0, 0), eyev, normalv, false)
      c2 = lighting(m, s, light, point(1.1, 0, 0), eyev, normalv, false)
    check(c1 =~ color(1, 1, 1))
    check(c2 =~ color(0, 0, 0))

  test "reflectivity for the default material":
    check(m.reflective == 0)

  test "transparency and refractive index for the default material":
    check(m.transparency == 0)
    check(m.refractive_index == 1.0)

  test "a helper for producing a sphere with glassy material":
    let a = glass_sphere()
    check(a.transform =~ identity)
    check(a.material.transparency == 1.0)
    check(a.material.refractive_index == 1.5)

  test "finding n1 and n2 at verious intersections":
    var
      A = glass_sphere()
      B = glass_sphere()
      C = glass_sphere()
    A.transform = scaling(2, 2, 2)
    A.material.refractive_index = 1.5
    B.transform = translation(0, 0, -0.25)
    B.material.refractive_index = 2.0
    C.transform = translation(0, 0, 0.25)
    C.material.refractive_index = 2.5
    let r = ray(point(0, 0, -4), vector(0, 0, 1))
    let xs = intersections(
      intersection(2.00, A),
      intersection(2.75, B),
      intersection(3.25, C),
      intersection(4.75, B),
      intersection(5.25, C),
      intersection(6.00, A))
    let cases = @[
      (0, 1.0, 1.5),
      (1, 1.5, 2.0),
      (2, 2.0, 2.5),
      (3, 2.5, 2.5),
      (4, 2.5, 1.5),
      (5, 1.5, 1.0)]
    for c in cases:
      let (index, n1, n2) = c
      let comps = prepare_computations(xs[index], r, xs)
      check(comps.n1 == n1)
      check(comps.n2 == n2)
