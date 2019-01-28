import unittest, math, pkglmx/core

suite "camera":
  test "constructing a camera":
    let
      hsize = 160
      vsize = 120
      fov = PI / 2
      c = camera(hsize, vsize, fov)
    check(c.hsize == 160)
    check(c.vsize == 120)
    check(c.fov == PI / 2)
    check(c.transform == identity)

  test "the pixel size for a horizontal canvas":
    let c = camera(200, 125, PI / 2)
    check(c.pixel_size =~ 0.01)

  test "the pixel size for a vertical canvas":
    let c = camera(125, 200, PI / 2)
    check(c.pixel_size =~ 0.01)

  test "constructing a ray through the center of the canvas":
    let
      c = camera(201, 101, PI / 2)
      r = ray_for_pixel(c, 100, 50)
    check(r.origin =~ point(0, 0, 0))
    check(r.direction =~ vector(0, 0, -1))

  test "constructing a ray through a corner of the canvas":
    let
      c = camera(201, 101, PI / 2)
      r = ray_for_pixel(c, 0, 0)
    check(r.origin =~ point(0, 0, 0))
    check(r.direction =~ vector(0.66519, 0.33259, -0.66851))

  test "constructing a ray when the camera is transformed":
    let c = camera(201, 101, PI / 2)
    c.transform = rotation_y(PI / 4) * translation(0, -2, 5)
    let r = ray_for_pixel(c, 100, 50)
    check(r.origin =~ point(0, 2, -5))
    check(r.direction =~ vector(sqrt(2.0) / 2, 0, -sqrt(2.0) / 2))

  test "rendering a world with a camera":
    let
      w = default_world()
      c = camera(11, 11, PI / 2)
      `from` = point(0, 0, -5)
      to = point(0, 0, 0)
      up = vector(0, 1, 0)
    c.transform = view_transform(`from`, to, up)
    let image = render(c, w)
    check(pixel_at(image, 5, 5) =~ color(0.38066, 0.47583, 0.2855))