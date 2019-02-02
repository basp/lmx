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

  var checkers = checkers_pattern(color(0.2, 0.5, 1), color(0, 0, 0.2))
  checkers.transform = scaling(2.0, 2.0, 2.0)

  let floor: Shape = plane()
  floor.material = material()
  floor.material.pattern = some(Pattern(checkers))

  let s1: Shape = sphere()
  s1.transform = translation(0, 1, 0)
  s1.material = material()
  s1.material.specular = 0.5
  s1.material.ambient = 0.02
  s1.material.diffuse = 0.02
  s1.material.reflective = 0.53
  s1.material.transparency = 0.98
  # s1.material.refractive_index = 1.00029 # air
  s1.material.refractive_index = 1.52 # water

  let s2: Shape = sphere()
  s2.transform = translation(-2, 0.5, 2.5) * scaling(0.5, 0.5, 0.5)
  s2.material = material()
  s2.material.color = color(0.3, 0.1, 0.8)
  s2.material.specular = 0.6

  let s3: Shape = sphere()
  s3.transform = translation(2, 0.5, -2.75) * scaling(0.5, 0.5, 0.5)
  s3.material = material()
  s3.material.color = color(0.3, 0.8, 0.2)
  s3.material.specular = 0.6

  let light = point_light(point(-10, 10, -10), color(1, 1, 1))

  var w = world()
  w.lights = @[light]
  w.objects = @[floor, s1, s2, s3]

  let c = camera(400, 200, PI / 3)
  c.transform = view_transform(point(5, 2.5, -2.5),
                               point(0, 0.5, 0),
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
