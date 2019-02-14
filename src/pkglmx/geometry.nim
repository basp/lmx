import math, strformat

type
  Vector3* = object
    x*, y*, z*: float
  Point3* = object
    x*, y*, z*: float
  Normal3* = object
    x*, y*, z*: float

proc initVector3*(x, y, z: float): Vector3 {.inline.} =
  result.x = x
  result.y = y
  result.z = z

proc initPoint3*(x, y, z: float): Point3 {.inline.} =
  result.x = x
  result.y = y
  result.z = z

proc initNormal3*(x, y, z: float): Normal3 {.inline.} =
  result.x = x
  result.y = y
  result.z = z

proc `$`*(v: Vector3): string =
  fmt"Vector3({v.x}, {v.y}, {v.z})"

proc `$`*(p: Point3): string =
  fmt"Point3({p.x}, {p.y}, {p.z})"

proc `$`*(n: Normal3): string =
  fmt"Normal3({n.x}, {n.y}, {n.z})"

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