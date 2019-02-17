import math, strformat

type
  Vector3* = object
    x*, y*, z*: float
  Point3* = object
    x*, y*, z*: float

proc initVector3*(x, y, z: float): Vector3 {.inline.} =
  result.x = x
  result.y = y
  result.z = z

proc initPoint3*(x, y, z: float): Point3 {.inline.} =
  result.x = x
  result.y = y
  result.z = z

proc `$`*(v: Vector3): string =
  fmt"Vector3({v.x}, {v.y}, {v.z})"

proc `$`*(p: Point3): string =
  fmt"Point3({p.x}, {p.y}, {p.z})"

proc `+`*(a, b: Vector3): Vector3 {.inline.} =
  result.x = a.x + b.x
  result.y = a.y + b.y
  result.z = a.z + b.z

proc `+=`*(a: var Vector3, b: Vector3) {.inline.} =
  a.x += b.x
  a.y += b.y
  a.z += b.z

proc `-`*(a, b: Vector3): Vector3 {.inline.} =
  result.x = a.x - b.x
  result.y = a.y - b.y
  result.z = a.z - b.z

proc `-=`*(a: var Vector3, b: Vector3) {.inline.} =
  a.x -= b.x
  a.y -= b.y
  a.z -= b.z

proc `*`*(v: Vector3, c: float): Vector3 {.inline.} =
  result.x = v.x * c
  result.y = v.y * c
  result.z = v.z * c

proc `*=`*(v: var Vector3, c: float) {.inline.} =
  v.x *= c
  v.y *= c
  v.z *= c

proc `/`*(v: Vector3, c: float): Vector3 {.inline.} =
  result.x = v.x / c
  result.y = v.y / c
  result.z = v.z / c

proc `/=`*(v: var Vector3, c: float) {.inline.} =
  v.x /= c
  v.y /= c
  v.z /= c

proc `-`*(a, b: Point3): Vector3 {.inline.} =
  result.x = a.x - b.x
  result.y = a.y - b.y
  result.z = a.z - b.z

proc `+`*(p: Point3, v: Vector3): Point3 {.inline.} =
  result.x = p.x + v.x
  result.y = p.y + v.y
  result.z = p.z + v.z

proc `+=`*(p: var Point3, v: Vector3) {.inline.} =
  p.x += v.x
  p.y += v.y
  p.z += v.z

proc `-`*(p: Point3, v: Vector3): Point3 {.inline.} =
  result.x = p.x - v.x
  result.y = p.y - v.y
  result.z = p.z - v.z

proc `-=`*(p: var Point3, v: Vector3) {.inline.} =
  p.x -= v.x
  p.y -= v.y
  p.z -= v.z

proc `-`*(v: Vector3): Vector3 {.inline.} =
  result.x = -v.x
  result.y = -v.y
  result.z = -v.z

proc magnitude*[T: Vector3](v: T): float {.inline.} =
  sqrt(v.x * v.x + v.y * v.y + v.z * v.z)

proc normalize*[T: Vector3](v: T): T {.inline.} =
  let factor = 1 / v.magnitude()
  result.x = v.x * factor
  result.y = v.y * factor
  result.z = v.z * factor

proc dot*(a, b: Vector3): float {.inline.} =
  a.x * b.x + a.y * b.y + a.z * b.z

proc cross*(a, b: Vector3): Vector3 {.inline.} =
  result.x = a.y * b.z - a.z * b.y
  result.y = a.z * b.x - a.x * b.z
  result.z = a.x * b.y - a.y * b.x

proc reflect*(v, n: Vector3): Vector3 {.inline.} =
  v - n * 2 * dot(v, n)

template vector*(x, y, z: float): Vector3 =
  initVector3(x, y, z)

template point*(x, y, z: float): Point3 =
  initPoint3(x, y, z)

template `[]`*(t: Vector3|Point3, i: int): float =
  case i 
  of 0: t.x
  of 1: t.y
  of 2: t.z
  else: raise newException(IndexError, "0 <= i < 3")

template `*`*(c: float, v: Vector3): Vector3 = 
  v * c

type
  Ray* = object
    origin*: Point3
    direction*: Vector3

proc initRay*(origin: Point3, direction: Vector3): Ray {.inline.} =
  result.origin = origin
  result.direction = direction

proc position*(ray: Ray, t: float): Point3 {.inline.} =
  ray.origin + t * ray.direction

template ray*(origin: Point3, direction: Vector3): Ray =
  initRay(origin, direction)