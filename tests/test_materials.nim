import unittest, math, options
import lmx, utils

const
  sqrt2over2 = sqrt(2.0) / 2

suite "materials":
  setup:
    var
      m = initMaterial()
      position = point(0, 0, 0)

  test "lighting with the eye between the light and the surface":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = newPointLight(point(0, 0, -10), color(1, 1, 1))
      s = newSphere()
      result = m.li(s, light, position, eyev, normalv)
    check(result =~ color(1.9, 1.9, 1.9))

  test "lighting with eye opposite surface, light offset 45 deg":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = newPointLight(point(0, 10, -10), color(1, 1, 1))
      s = newSphere()
      result = m.li(s, light, position, eyev, normalv)
    check(result =~ color(0.7364, 0.7364, 0.7364))

  test "lighting with eye in path of reflection vector":
    let
      eyev = vector(0, -sqrt2over2, -sqrt2over2)
      normalv = vector(0, 0, -1)
      light = newPointLight(point(0, 10, -10), color(1, 1, 1))
      s = newSphere()
      result = m.li(s, light, position, eyev, normalv)
    check(result =~ color(1.6364, 1.6364, 1.6364))

  test "lighting with the light behind the surface":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = newPointLight(point(0, 0, 10), color(1, 1, 1))
      s = newSphere()
      result = m.li(s, light, position, eyev, normalv)
    check(result =~ color(0.1, 0.1, 0.1))

  test "lighting with the surface in shadow":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = newPointLight(point(0, 0, -10), color(1, 1, 1))
      shadow = true
      s = newSphere()
      result = m.li(s, light, position, eyev, normalv, shadow)
    check(result =~ color(0.1, 0.1, 0.1))

  test "lighting with a pattern applied":
    let 
      pat = newStripePattern(color(1, 1, 1), color(0, 0, 0))
      s = newSphere()
    m.pattern = some(Pattern(pat))
    m.ambient = 1
    m.diffuse = 0
    m.specular = 0
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = newPointLight(point(0, 0, -10), color(1, 1, 1))
      c1 = m.li(s, light, point(0.9, 0, 0), eyev, normalv, false)
      c2 = m.li(s, light, point(1.1, 0, 0), eyev, normalv, false)
    check(c1 =~ color(1, 1, 1))
    check(c2 =~ color(0, 0, 0))

  test "reflectivity for the default material":
    check(m.reflective == 0)