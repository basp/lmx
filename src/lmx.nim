import os, math, sequtils, options, algorithm

type
  Vec4* = tuple[x: float, y: float, z: float, w: float]
  Color* = tuple[r: float, g: float, b: float]
  Matrix*[N: static[int]] = array[0..N-1, array[0..N-1, float]]
  Ray* = tuple[origin: Vec4, direction: Vec4]
  Sphere = object of RootObj
    transform*: Matrix[4]
  Intersection = tuple[t: float, obj: Sphere]

const identity* : Matrix[4] = [[1.0, 0.0, 0.0, 0.0],
                               [0.0, 1.0, 0.0, 0.0],
                               [0.0, 0.0, 1.0, 0.0],
                               [0.0, 0.0, 0.0, 1.0]]

proc isPoint*(v: Vec4): bool {.inline.} =
  v.w == 1.0

proc isVector*(v: Vec4): bool {.inline.} =
  v.w == 0.0

proc point*(x: float, y: float, z: float): Vec4 {.inline.} =
  (x, y, z, 1.0)

proc vector*(x: float, y: float, z: float): Vec4 {.inline.} =
  (x, y, z, 0.0)

proc color*(r: float, g: float, b: float): Color {.inline.} =
  (r, g, b)

proc `=~`*(a: float, b: float): bool {.inline.} =
  const epsilon = 0.00001
  abs(a - b) < epsilon

proc `=~`*(a: Vec4, b: Vec4): bool {.inline.} =
  a.x =~ b.x and a.y =~ b.y and a.z =~ b.z and a.w =~ b.w

proc `=~`*(a: Color, b: Color): bool {.inline.} =
  a.r =~ b.r and a.g =~ b.g and a.b =~ b.b

proc `+`*(a: Vec4, b: Vec4): Vec4 {.inline.} =
  (a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)

proc `+`*(a: Color, b: Color): Color {.inline.} =
  (a.r + b.r, a.g + b.g, a.b + b.b)

proc `-`*(a: Vec4, b: Vec4): Vec4 {.inline.} =
  (a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)

proc `-`*(a: Color, b: Color): Color {.inline.} =
  (a.r - b.r, a.g - b.g, a.b - b.b)

proc `-`*(a: Vec4): Vec4 {.inline.} =
  (-a.x, -a.y, -a.z, -a.w)

proc `*`*(c: float, a: Vec4): Vec4 {.inline.} =
  (c * a.x, c * a.y, c * a.z, c * a.w)

proc `*`*(c: float, a: Color): Color {.inline.} =
  (c * a.r, c * a.g, c * a.b)

proc `*`*(a: Vec4, c: float): Vec4 {.inline.} =
  (c * a.x, c * a.y, c * a.z, c * a.w)

proc `*`*(a: Color, c: float): Color {.inline.} =
  (c * a.r, c * a.g, c * a.b)

proc `*`*(a: Color, b: Color): Color {.inline.} =
  (a.r * b.r, a.g * b.g, a.b * b.b)

proc `/`*(a: Vec4, c: float): Vec4 {.inline.} =
  (a.x / c, a.y / c, a.z / c, a.w / c)

proc magnitude*(a: Vec4): float {.inline.} =
  sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)

proc normalize*(a: Vec4): Vec4 {.inline.} =
  let mag = magnitude(a)
  (a.x / mag, a.y / mag, a.z / mag, a.w / mag)

proc dot*(a: Vec4, b: Vec4): float {.inline.} =
  a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w

proc cross*(a: Vec4, b: Vec4): Vec4 {.inline.} =
  vector(a.y * b.z - a.z * b.y,
         a.z * b.x - a.x * b.z,
         a.x * b.y - a.y * b.x)

proc `[]`*[N](m: Matrix[N], row: int, col: int): float {.inline.} =
  m[row][col]

proc row*[N](m: Matrix[N], row: int): Vec4 {.inline.} =
  (m[row][0], m[row][1], m[row][2], m[row][3])

proc col*[N](m: Matrix[N], col: int): Vec4 {.inline.} =
  (m[0][col], m[1][col], m[2][col], m[3][col])

proc `=~`*[N](a, b: Matrix[N]): bool {.inline.} =
  for r in 0..N-1:
    for c in 0..N-1:
      if not (a[r][c] =~ b[r][c]):
        return false
  true     

proc `*`*[N](a, b: Matrix[N]): Matrix[N] {.inline.} =
  var z : Matrix[N]
  for r in 0..N-1:
    for c in 0..N-1:
      z[r][c] = dot(row(a, r), col(b, c))
  z

proc `*`*(a: Matrix[4], b: Vec4): Vec4 {.inline.} =
  (dot(row(a, 0), b), dot(row(a, 1), b), dot(row(a, 2), b), dot(row(a, 3), b))

proc transpose*[N](a: Matrix[N]): Matrix[N] {.inline.} =
  var b: Matrix[N]
  for r in 0..N-1:
    for c in 0..N-1:
      b[c][r] = a[r][c]
  b

proc determinant*(a: Matrix[2]): float {.inline.} =
  a[0][0] * a[1][1] - a[0][1] * a[1][0]

proc submatrix[N, M](a: Matrix[N], row: int, col: int): Matrix[M] {.inline.} =
  let 
    idxs = toSeq 0..N-1
    rows = filter(idxs) do (i: int) -> bool : i != row
    cols = filter(idxs) do (i: int) -> bool : i != col
  var b: Matrix[M]
  for r in 0..high(rows):
    for c in 0..high(cols):
      b[r][c] = a[rows[r]][cols[c]]
  b  

proc submatrix*(a: Matrix[3], row: int, col: int): Matrix[2] {.inline.} =
  submatrix[3, 2](a, row, col)

proc submatrix*(a: Matrix[4], row: int, col: int): Matrix[3] {.inline.} =
  submatrix[4, 3](a, row, col)

proc minor*(a: Matrix[3], row: int, col: int): float {.inline.} =
  submatrix[3, 2](a, row, col).determinant()

proc cofactor*(a: Matrix[3], row: int, col: int): float {.inline.} =
  let m = minor(a, row, col)
  if (row + col) mod 2 == 0: m else: -m

proc determinant*(a: Matrix[3]): float {.inline.} =
  let 
    x = a[0][0] * cofactor(a, 0, 0)
    y = a[0][1] * cofactor(a, 0, 1)
    z = a[0][2] * cofactor(a, 0, 2)
  x + y + z

proc minor*(a: Matrix[4], row: int, col: int): float {.inline.} =
  submatrix[4, 3](a, row, col).determinant()

proc cofactor*(a: Matrix[4], row: int, col: int): float {.inline.} =
  let m = minor(a, row, col)
  if (row + col) mod 2 == 0: m else: -m

proc determinant*(a: Matrix[4]): float {.inline.} =
  let 
    x = a[0][0] * cofactor(a, 0, 0)
    y = a[0][1] * cofactor(a, 0, 1)
    z = a[0][2] * cofactor(a, 0, 2)
    w = a[0][3] * cofactor(a, 0, 3)
  x + y + z + w

proc isInvertible*(a: Matrix[4]): bool {.inline.} =
  not (determinant(a) =~ 0)

proc inverse*(a: Matrix[4]): Matrix[4] =
  let d = determinant(a)
  if d =~ 0: raise newException(Exception, "matrix is not invertible")
  var b: Matrix[4]
  for row in 0..3:
    for col in 0..3:
      let c = cofactor(a, row, col)
      b[col][row] = c / d #transposed
  b

proc translation*(x: float, y: float, z: float): Matrix[4] {.inline.} =
  [[1.0, 0.0, 0.0, x],
   [0.0, 1.0, 0.0, y],
   [0.0, 0.0, 1.0, z],
   [0.0, 0.0, 0.0, 1.0]]  

proc scaling*(x: float, y: float, z: float): Matrix[4] {.inline.} =
  [[x, 0.0, 0.0, 0.0],
   [0.0, y, 0.0, 0.0],
   [0.0, 0.0, z, 0.0],
   [0.0, 0.0, 0.0, 1.0]]

proc rotationX*(r: float): Matrix[4] {.inline.} =
  [[1.0, 0.0, 0.0, 0.0],
   [0.0, cos(r), -sin(r), 0.0],
   [0.0, sin(r), cos(r), 0.0],
   [0.0, 0.0, 0.0, 1.0]]

proc rotationY*(r: float): Matrix[4] {.inline.} =
  [[cos(r), 0.0, sin(r), 0.0],
   [0.0, 1.0, 0.0, 0.0],
   [-sin(r), 0.0, cos(r), 0.0],
   [0.0, 0.0, 0.0, 1.0]]

proc rotationZ*(r: float): Matrix[4] {.inline.} =
  [[cos(r), -sin(r), 0.0, 0.0],
   [sin(r), cos(r), 0.0, 0.0],
   [0.0, 0.0, 1.0, 0.0],
   [0.0, 0.0, 0.0, 1.0]]

proc shearing*(xy: float, xz: float, 
               yx: float, yz: float, 
               zx: float, zy: float): Matrix[4] {.inline.} =
  [[1.0, xy, xz, 0.0],
   [yx, 1.0, yz, 0.0],
   [zx, zy, 1.0, 0.0],
   [0.0, 0.0, 0.0, 1.0]]

proc ray*(origin: Vec4, direction: Vec4): Ray {.inline.} =
  (origin, direction)

proc position*(ray: Ray, t: float): Vec4 {.inline.} =
  ray.origin + ray.direction * t

proc sphere*(): Sphere {.inline.} = 
  Sphere(transform: identity)

proc intersection*(t: float, obj: Sphere): Intersection {.inline.} =
  (t, obj)

proc intersections*(xs: varargs[Intersection]): seq[Intersection] {.inline.} =
  @(xs)

proc hit*(xs: seq[Intersection]): Option[Intersection] {.inline.} =
  var valid = filter(xs) do (i: Intersection) -> bool : i.t >= 0
  if len(valid) == 0: return none(Intersection)
  valid.sort do (x, y: Intersection) -> int: system.cmp(x.t, y.t)
  return some(valid[0])

proc transform*(ray: Ray, t: Matrix[4]): Ray {.inline.} =
  (t * ray.origin, t * ray.direction)

proc intersect*(obj: Sphere, ray: Ray): seq[Intersection] {.inline.} =
  var tr = transform(ray, inverse(obj.transform))
  let
    # the vector from the sphere's center to the ray's origin
    # note: sphere is assumed to be at origin
    sphereToRay = tr.origin - point(0, 0, 0)
    a = dot(tr.direction, tr.direction)
    b = 2 * dot(tr.direction, sphereToRay)
    c = dot(sphereToRay, sphereToRay) - 1.0
    discriminant = b * b - 4 * a * c
  if discriminant < 0: return @[]
  let
    t1 = (-b - sqrt(discriminant)) / (2 * a)
    t2 = (-b + sqrt(discriminant)) / (2 * a)
  @[(t1, obj), (t2, obj)]

proc getColor256(c: Color): tuple[r: int, g: int, b: int] =
  let
    r = int(255.99 * c.r)
    g = int(255.99 * c.g)
    b = int(255.99 * c.b)
  (r, g, b)

when isMainModule:
  var shape = sphere()
  let
     c = color(1, 0, 0)
     black = getColor256(color(0, 0, 0))
     ic = getColor256(c)
     wallZ = 10.0
     wallSize = 7.0
     canvasPixels = 100
     pixelSize = wallSize / float(canvasPixels)
     half = wallSize / 2
     rayOrigin = point(0, 0, -5)
     f = open("out.ppm", fmWrite)

  #shape.transform = scaling(1, 0.5, 1)
  #shape.transform = scaling(0.5, 1, 1)
  #shape.transform = rotation_z(PI / 4) * scaling(0.5, 1, 1) #remember, reverse application, scaling goes first
  shape.transform = shearing(1, 0, 0, 0, 0, 0)

  writeLine(f, "P3")
  writeLine(f, canvasPixels, " ", canvasPixels)
  writeLine(f, 255)

  for y in 0..canvasPixels - 1:
    let worldY = half - pixelSize * float(y)
    for x in 0..canvasPIxels - 1:
      let 
        worldX = -half + pixelSize * float(x)
        position = point(worldX, worldY, wallZ)
        r = ray(rayOrigin, normalize(position - rayOrigin))
        xs = intersect(shape, r)
        h = hit(xs)
      if h.isSome():
        writeLine(f, ic.r, " ", ic.g, " ", ic.b)
      else:
        writeLIne(f, black.r, " ", black.g, " ", black.b)
