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

  var w = world()

  var checkers = checkers_pattern(color(1, 1, 1), color(0, 0, 0))
  checkers.transform = scaling(0.5, 0.5, 0.5)

  let floor: Shape = plane()
  floor.material = material()
  floor.material.pattern = some(Pattern(checkers))

  let sphere: Shape = sphere()
  sphere.transform = translation(0, 1, 0)
  sphere.material = material()
  sphere.material.transparency = 1.0
  sphere.material.refractive_index = 1.52

  let light = point_light(point(-10, 10, -10), color(1, 1, 1))

  w.lights = @[light]
  w.objects = @[floor, sphere]

  let c = camera(400, 200, PI / 3)
  c.transform = view_transform(point(0, 5, 0),
                               point(0, 0, 0),
                               vector(0, 0, 1))
  
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
