import math, options, times

import pkglmx/core, 
       pkglmx/linalg, 
       pkglmx/patterns,
       pkglmx/shapes, 
       pkglmx/canvas, 
       pkglmx/utils

export core, linalg, patterns, shapes, canvas, utils

when is_main_module:
  proc clamp(value: int, min: int, max: int): int {.inline.} =
    if value < min: return min
    if value > max: return max
    value

  proc getRGB(c: Color): tuple[r: int, g: int, b: int] =
    # make sure we don't overflow colors (i.e. keep r, g, b <= 255)
    let
      r = int(255.99 * c.r).clamp(0, 255)
      g = int(255.99 * c.g).clamp(0, 255)
      b = int(255.99 * c.b).clamp(0, 255)
    (r, g, b)

  let checkers: Pattern = checkers_pattern(color(1, 1, 1), color(0, 0, 0.0))
  checkers.transform = identity

  let 
    p1: Shape = plane()
    p2: Shape = plane()
    p3: Shape = plane()
    p4: Shape = plane()
    p5: Shape = plane()
    p6: Shape = plane()

  p1.material = material()
  p1.material.pattern = some(checkers)
  p1.transform = identity

  p2.material = material()
  p2.material.pattern = some(checkers)
  p2.transform = translation(-7, 0, 0) * rotation_z(-PI / 2)

  p3.material = material()
  p3.material.pattern = some(checkers)
  p3.transform = translation(0, 0, 7) * rotation_x(PI / 2)

  p4.material = material()
  p4.material.pattern = some(checkers)
  p4.transform = translation(7, 0, 0) * rotation_z(PI / 2)

  p5.material = material()
  p5.material.pattern = some(checkers)
  p5.transform = translation(0, 0, -7) * rotation_x(-PI / 2)

  p6.material = material()
  p6.material.pattern = some(checkers)
  p6.transform = translation(0, 7, 0) * rotation_x(PI)

  let s: Shape = sphere()
  s.material = material()
  s.material.color = color(0.0, 0.0, 0.0)
  s.material.reflective = 0.4
  s.material.specular = 0.4
  s.material.diffuse = 0.001
  s.material.ambient = 0.001
  s.transform = translation(0, 1.0, 0)  

  let light = point_light(point(1, 3, -3), color(1, 1, 1))

  var w = world()
  w.lights = @[light]
  w.objects = @[s, p1, p2, p3, p4, p5, p6]

  let c = camera(400, 200, PI / 3)
  c.transform = view_transform(point(2.5, 3.0, -2.5),
                               point(0, 1.0, 0),
                               vector(0, 1, 0))
  
  let start = now()
  let img = render(c, w, true)
  let f = open("out.ppm", fmWrite)
  write_line(f, "P3")
  write_line(f, img.hsize, " ", img.vsize)
  write_line(f, 255)

  for y in 0..pred(img.vsize):
    for x in 0..pred(img.hsize):
      let rgb = pixel_at(img, x, y).getRGB()
      write_line(f, rgb.r, " ", rgb.g, " ", rgb.b)

  let finish = now()
  let duration = finish - start
  echo duration
