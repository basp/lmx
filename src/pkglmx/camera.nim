import math
import geometry, transform, world, canvas

type
  Camera = ref object of RootObj
    hsize*, vsize*: int
    fov*, pixelSize*, halfwidth, halfHeight: float
    transform*: Transform

proc newCamera*(hsize, vsize: int, fov: float): Camera {.inline.} =
  result = new Camera
  result.hsize = hsize
  result.vsize = vsize
  result.fov = fov
  result.transform = initTransform(identityMatrix)
  let
    halfView = tan(fov / 2)
    aspect = hsize / vsize
  if aspect >= 1:
    result.halfWidth = halfView
    result.halfHeight = halfView / aspect
  else:
    result.halfWidth = halfView * aspect
    result.halfHeight = halfView
  result.pixelSize = (result.halfWidth * 2) / float(hsize)

proc rayForPixel*(c: Camera, px, py: int): Ray {.inline.} =
  let
    xOffset = (float(px) + 0.5) * c.pixelSize
    yOffset = (float(py) + 0.5) * c.pixelSize
    worldX = c.halfwidth - xOffset
    worldY = c.halfHeight - yOffset
    pixel = c.transform.inv * point(worldX, worldY, -1)
    origin = c.transform.inv * point(0, 0, 0)
    direction = normalize(pixel - origin)
  initRay(origin, direction)

proc render*(c: Camera, w: World): Canvas =
  result = newCanvas(c.hsize, c.vsize)
  for y in 0..pred(c.vsize):
    for x in 0..pred(c.hsize):
      let
        ray = c.rayForPixel(x, y)
        color = w.colorAt(ray)
      result[x, y] = color
      