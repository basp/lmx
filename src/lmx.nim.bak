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

  var red_grey_stripes = stripe_pattern(color(0.4, 0.3, 0.3), color(0.1, 0.1, 0.1))
  var grey_black_stripes = stripe_pattern(color(0.2, 0.2, 0.2), color(0.0, 0.0, 0.0))
  
  var blue_grey_stripes = stripe_pattern(color(0.1, 0.3, 0.95), color(0.5, 0.5, 0.5))
  blue_grey_stripes.transform = scaling(0.5, 0, 0) * rotation_x(PI / 4)
  
  var pink_blue_stripes = stripe_pattern(color(0.9, 0.05, 0.6), color(0.2, 0.2, 1.0))
  pink_blue_stripes.transform = scaling(0.25, 0.25, 0.25)

  var g1 = gradient_pattern(color(0.0, 0.0, 1.0), color(0.0, 1, 0))
  # make sure to transform it so the gradient won't overflow
  g1.transform = translation(-1, 0, 0) * scaling(2, 2, 2)

  var checkers = checkers_pattern(color(0.8, 0.1, 0.8), color(0, 0, 0))
  checkers.transform = scaling(2, 2, 2)

  let floor: Shape = plane()
  floor.material = material()
  floor.material.color = color(1, 0.9, 0.9)
  floor.material.reflective = 0.23
  floor.material.specular = 0
  floor.material.pattern = some(Pattern(checkers))

  let backdrop: Shape = plane()
  backdrop.material = material()
  backdrop.material.reflective = 0.93
  backdrop.material.color = color(0, 0, 0)
  backdrop.material.specular = 0
  # backdrop.material.pattern = some(Pattern(red_grey_stripes))
  backdrop.transform = translation(0, 0, 3.3) * 
                       rotation_x(-PI / 2)

  let middle: Shape = sphere()
  middle.transform = translation(-0.5, 1.0, 0.5) * rotation_z(PI / 5)
  middle.material = material()
  middle.material.color = color(0.1, 1, 0.5)
  middle.material.diffuse = 0.7
  middle.material.specular = 0.3
  middle.material.pattern = some(Pattern(pink_blue_stripes))

  let right: Shape = sphere()
  right.transform = translation(1.52, 0.54, -0.5) *
                    scaling(0.5, 0.5, 0.5)
  right.material.reflective = 0.32
  right.material = material()
  right.material.color = color(0.5, 1, 0.1)
  right.material.diffuse = 0.7
  right.material.specular = 0.3

  let left: Shape = sphere()
  left.transform = translation(-1.5, 0.33, -0.75) *
                   scaling(0.33, 0.33, 0.33)
  left.material = material()
  #left.material.reflective = 0.43
  left.material.pattern = some(Pattern(g1))
  left.material.color = color(1, 0.8, 0.1)
  left.material.diffuse = 0.7
  left.material.specular = 0.3

  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  let l2 = point_light(point(10, 10, -10), color(0.2, 0.15, 0.7))
  let l3 = point_light(point(2, 5, -10), color(0.3, 0.7, 0.2))

  #w.lights = @[light, l2, l3]
  w.lights = @[light]
  w.objects = @[floor, backdrop, middle, right, left]

  let c = camera(800, 600, PI / 3)
  c.transform = view_transform(point(-2.45, 4.63, -5.2),
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
