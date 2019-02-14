import math

import pkglmx/geometry,
       pkglmx/transform,
       pkglmx/colors,
       pkglmx/world,
       pkglmx/canvas

export geometry,
       transform,
       colors,
       world,
       canvas

when isMainModule:
  let 
    c = newCanvas(400, 400)
    p = point(0, 1, 0)
  const n = 12
  for i in 0..pred(n):
    let 
      r = float(i) * (2 * PI / n)
      t = identityMatrix.
        rotateZ(r).
        scale(180, 180, 1).
        translate(200, 200, 0)
      pt = t * p
      ix = int(pt.x)
      iy = int(pt.y)
    c[ix, iy] = initColor(1, 1, 1)
  c.savePPM("out.ppm")
