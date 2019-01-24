import math

type
  Vec4* = tuple[x: float, y: float, z: float, w: float]
  Color* = tuple[r: float, g: float, b: float]

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

when isMainModule:
  echo("Hello, World!")
