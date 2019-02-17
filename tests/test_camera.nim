import unittest, math
import lmx, utils

suite "camera":
  test "constructing a camera":
    let
      hsize = 160
      vsize = 120
      fov = PI / 2
      c = newCamera(hsize, vsize, fov)
    check(c.vsize == 120)
    check(c.hsize == 160)
    check(c.fov == PI / 2)
    check(c.transform.m == identityMatrix)

  test "the pixel size for a landscape canvas":
    let c = newCamera(200, 125, PI / 2)
    check(c.pixelSize =~ 0.01)

  test "the pixel size for a portrait canvas":
    let c = newCamera(125, 200, PI / 2)
    check(c.pixelSize =~ 0.01)

  test "constructing a ray through the center of the canvas":
    let 
      c = newCamera(201, 101, PI / 2)
      r = c.rayForPixel(100, 50)
    check(r.origin =~ point(0, 0, 0))
    check(r.direction =~ vector(0, 0, -1))

  test "constructing a ray through a corner of the canvas":
    let
      c = newCamera(201, 101, PI / 2)
      r = c.rayForPixel(0, 0)
    check(r.origin =~ point(0, 0, 0))
    check(r.direction =~ vector(0.66519, 0.33259, -0.66851))

  test "constructing a ray when the camera is transformed":
    let c = newCamera(201, 101, PI / 2)
    let m = rotationY(PI / 4) * translation(0, -2, 5)
    c.transform = initTransform(m)
    let r = c.rayForPixel(100, 50)
    check(r.origin =~ point(0, 2, -5))
    check(r.direction =~ vector(sqrt2over2, 0, -sqrt2over2))

  test "rendering a world with a camera":
    let
      w = newDefaultWorld()
      c = newCamera(11, 11, PI / 2)
      `from` = point(0, 0, -5)
      to = point(0, 0, 0)
      up = vector(0, 1, 0)
      m = view(`from`, to, up)
    c.transform = initTransform(m)
    let img = c.render(w)
    check(img[5, 5] =~ color(0.38066, 0.47583, 0.2855))
