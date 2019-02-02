import math, fenv, sequtils

type
  Float* = float32
  Number* = Float | int

converter toFloat*(v: int): Float = 
  ## Converts ``v`` to a ``Float``.
  Float(v)

template isNan*(x: int): bool = 
  ## An integer is always a number so this returns ``false``.
  false

template isNan*(x: Float): bool = 
  ## Returns ``true`` if the value ``x`` is not a number.
  classify(x) == fcNan

type
  Vector3*[T: Number] = object
    x, y, z: T
  Point3*[T: Number] = object
    x, y, z: T
  Vector3f* = Vector3[Float]
  Point3f* = Point3[Float]

proc initVector3*[T](x, y, z: T): Vector3[T] {.inline.} =
  result.x = x
  result.y = y
  result.z = z

proc `+`*[T](a, b: Vector3[T]): Vector3[T] {.inline.} =
  result.x = a.x + b.x
  result.y = a.y + b.y
  result.z = a.z + b.z