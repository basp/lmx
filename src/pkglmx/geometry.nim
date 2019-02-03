# this module is to replace linalg eventually
import math, fenv, sequtils
import common

converter toFloat*(v: float64): Float {.inline.} =
  ## Crudely converts a double to a ``Float``.
  Float(v)

converter toFloat*(v: int): Float {.inline.} = 
  ## Converts an integer to a ``Float``.
  Float(v)

template isNan*(x: int): bool = 
  ## An integer is always a number so this returns ``false``.
  false

template isNan*(x: Float): bool = 
  ## Returns ``true`` if the value ``x`` is not a number.
  classify(x) == fcNan

type
  Vector3*[T: Number] = object
    x*, y*, z*: T
  Point3*[T: Number] = object
    x*, y*, z*: T
  Vector3f* = Vector3[Float]
  Vector3i* = Vector3[int]
  Point3f* = Point3[Float]

converter toVector3f*(v: Vector3i): Vector3f {.inline.} =
  ## A ``Vector3i`` is always convertible to a ``Vector3f``.
  result.x = Float(v.x)
  result.y = Float(v.y)
  result.z = Float(v.z)

proc initVector3*[T: Number](x, y, z: T): Vector3[T] {.inline.} =
  ## Initializes a new vector with components of type ``T``.
  result.x = x
  result.y = y
  result.z = z

proc initPoint3*[T: Number](x, y, z: T): Point3[T] {.inline.} =
  ## Initializes a new point with components of type ``T``.
  result.x = x
  result.y = y
  result.z = z

proc `+`*[T](a, b: Vector3[T]): Vector3[T] {.inline.} =
  ## Adding two vectors yields a new vector.
  result.x = a.x + b.x
  result.y = a.y + b.y
  result.z = a.z + b.z

proc `-`*[T](a, b: Point3[T]): Vector3[T] {.inline.} =
  ## Subtracting two points yields a vector.
  result.x = a.x - b.x
  result.y = a.y - b.y
  result.z = a.z - b.z

proc `-`*[T](p: Point3[T], v: Vector3[T]): Point3[T] {.inline.} =
  ## Subtracting a vector from a point yields a new point.
  result.x = p.x - v.x
  result.y = p.y - v.y
  result.z = p.z - v.z

proc `-`*[T](a, b: Vector3[T]): Vector3[T] {.inline.} =
  ## Subtracting two vectors yields a new vector.
  result.x = a.x - b.x
  result.y = a.y - b.y
  result.z = a.z - b.z

proc `-`*[T](v: Vector3[T]): Vector3[T] {.inline.} =
  ## Negating a vector is like reflecting it.
  result.x = -v.x
  result.y = -v.y
  result.z = -v.z

proc `*`*[T](v: Vector3[T], c: T): Vector3[T] {.inline.} =
  ## Multiplying by a scalar makes it longer or shorter.
  result.x = v.x * c
  result.y = v.y * c
  result.z = v.z * c

proc `/`*[T](v: Vector3[T], c: T): Vector3f {.inline.} =
  ## Dividing is just the opposite of multiplying.
  result.x = v.x / c
  result.y = v.y / c
  result.z = v.z / c

proc magnitude*[T](v: Vector3[T]): Float {.inline.} =
  ## The *length* or *magnitude* of a vector. We prefer
  ## magnitude because length might be confusing with the
  ## number of elements the vector has.
  sqrt(v.x * v.x + v.y * v.y + v.z * v.z)

proc normalize*[T](v: Vector3[T]): Vector3f {.inline.} =
  ## Returns a normalized vector by dividing each of the 
  ## components by the ``magnitude`` of the vector.
  let mag = magnitude(v)
  result.x = v.x / mag
  result.y = v.y / mag
  result.z = v.z / mag

proc dot*[T](a, b: Vector3[T]): T  =
  ## The *dot product* of two vectors.
  a.x * b.x + a.y * b.y + a.z * b.z

proc cross*[T](a, b: Vector3[T]): Vector3[T] =
  ## The *cross product* of two vectors.
  initVector3(a.y * b.z - a.z * b.y,
              a.z * b.x - a.x * b.z,
              a.x * b.y - a.y * b.x)

proc reflect*[T](v, normal: Vector3[T]): Vector3[T] =
  v - normal * 2 * dot(v, normal)