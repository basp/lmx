import unittest, math
import lmx, utils

suite "lights":
  test "a point light has a position and intensity":
    let
      intensity = color(1, 1, 1)
      position = point(0, 0, 0)
      light = newPointLight(position, intensity)
    check(light.position =~ position)
    check(light.intensity =~ intensity)
  