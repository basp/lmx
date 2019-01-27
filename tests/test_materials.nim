import unittest, math, lmx

suite "materials":
  setup:
    let 
      m = material()
      position = point(0, 0, 0)

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
      result = lighting(m, light, position, eyev, normalv)
    check(result =~ color(1.9, 1.9, 1.9))

  test "lighting with the eye between light and surface, eye offset 45 degrees":
    let
      eyev = vector(0, sqrt(2.0) / 2, -sqrt(2.0) / 2)
      normalv = vector(0, 0, -1)
      light = point_light(point(0, 0, -10), color(1, 1, 1))
      result = lighting(m, light, position, eyev, normalv)
    check(result =~ color(1.0, 1.0, 1.0))

  test "lighting with eye opposite surface, light offset 45 degrees":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = point_light(point(0, 10, -10), color(1, 1, 1))
      result = lighting(m, light, position, eyev, normalv)
    check(result =~ color(0.7364, 0.7364, 0.7364))
    
  test "lighting with eye in the path of the reflection vector":
    let
      eyev = vector(0, -sqrt(2.0) / 2.0, -sqrt(2.0) / 2.0)
      normalv = vector(0, 0, -1)
      light = point_light(point(0, 10, -10), color(1, 1, 1))
      result = lighting(m, light, position, eyev, normalv)
    check(result =~ color(1.6364, 1.6364, 1.6364))

  test "lighting with the light behind the surface":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = point_light(point(0, 0, 10), color(1, 1, 1))
      result = lighting(m, light, position, eyev, normalv)
    check(result =~ color(0.1, 0.1, 0.1))
    
  test "lighting with the surface in shadow":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, 1)
      light = point_light(point(0, 0, -10), color(1, 1, 1))
      in_shadow = true
      result = lighting(m, light, position, eyev, normalv, in_shadow)
    check(result =~ color(0.1, 0.1, 0.1))