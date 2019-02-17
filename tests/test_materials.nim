import unittest, math
import lmx, utils

const
  sqrt2over2 = sqrt(2.0) / 2

suite "materials":
  setup:
    let 
      m = initMaterial()
      position = point(0, 0, 0)

  test "lighting with the eye between the light and the surface":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = newPointLight(point(0, 0, -10), color(1, 1, 1))
      result = m.li(light, position, eyev, normalv)
    check(result =~ color(1.9, 1.9, 1.9))

  test "lighting with eye opposite surface, light offset 45 deg":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = newPointLight(point(0, 10, -10), color(1, 1, 1))
      result = m.li(light, position, eyev, normalv)
    check(result =~ color(0.7364, 0.7364, 0.7364))

  test "lighting with eye in path of reflection vector":
    let
      eyev = vector(0, -sqrt2over2, -sqrt2over2)
      normalv = vector(0, 0, -1)
      light = newPointLight(point(0, 10, -10), color(1, 1, 1))
      result = m.li(light, position, eyev, normalv)
    check(result =~ color(1.6364, 1.6364, 1.6364))

  test "lighting with the light behind the surface":
    let
      eyev = vector(0, 0, -1)
      normalv = vector(0, 0, -1)
      light = newPointLight(point(0, 0, 10), color(1, 1, 1))
      result = m.li(light, position, eyev, normalv)
    check(result =~ color(0.1, 0.1, 0.1))