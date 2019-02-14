import math, algorithm, options
import geometry

type
  Shape* = ref object of RootObj
  Sphere* = ref object of Shape
  Intersection = object
    t*: float
    obj*: Shape        

proc initIntersection*(t: float, obj: Shape): Intersection {.inline.} =
  result.t = t
  result.obj = obj

template intersection*(t: float, obj: Shape): Intersection =
  initIntersection(t, obj)

proc intersections*(xs: varargs[Intersection]): seq[Intersection] {.inline.} =
  result = @(xs)
  result.sort do (x, y: Intersection) -> int: cmp(x.t, y.t)
  
proc tryGetHit*(xs: seq[Intersection]): Option[Intersection] =
  for i in xs:
    if i.t > 0: 
      return some(i)
  none(Intersection)

proc newSphere*(): Sphere {.inline.} =
  result = new Sphere

method intersect*(s: Shape, r: Ray): seq[float] {.base.} =
  raise newException(Exception, "not implemented")

method intersect*(s: Sphere, r: Ray): seq[float] =
  let
    sphereToRay = r.origin - point(0, 0, 0)
    a = dot(r.direction, r.direction)
    b = 2 * dot(r.direction, sphereToRay)
    c = dot(sphereToRay, sphereToRay) - 1
    discriminant = b * b - 4 * a * c
  if discriminant < 0: return @[]
  let
    t1 = (-b - sqrt(discriminant)) / (2 * a)
    t2 = (-b + sqrt(discriminant)) / (2 * a)
  @[t1, t2]
  
