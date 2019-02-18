import math
import geometry, transform, common

type
  Sphere* = ref object of Shape
  Plane* = ref object of Shape

proc newSphere*(): Sphere {.inline.} =
  result = new Sphere
  result.transform = initTransform(identityMatrix)
  result.material = initMaterial()

proc newPlane*(): Plane {.inline.} =
  result = new Plane
  result.transform = initTransform(identityMatrix)
  result.material = initMaterial()

method localIntersect*(s: Sphere, r: Ray): seq[Intersection] =
  let
    # convert origin to a vector so we can dot it
    sphereToRay = r.origin - point(0, 0, 0)
    a = dot(r.direction, r.direction)
    b = 2 * dot(r.direction, sphereToRay)
    c = dot(sphereToRay, sphereToRay) - 1
    discriminant = b * b - 4 * a * c
  if discriminant < 0: return @[]
  let
    t1 = (-b - sqrt(discriminant)) / (2 * a)
    t2 = (-b + sqrt(discriminant)) / (2 * a)
  intersections(
    intersection(t1, s),
    intersection(t2, s))

method localNormalAt*(s: Sphere, objPoint: Point3): Vector3 =
  objPoint - point(0, 0, 0)

method localIntersect*(s: Plane, r: Ray): seq[Intersection] =
  if abs(r.direction.y) < epsilon: return @[]
  let t = -r.origin.y / r.direction.y
  @[intersection(t, s)]

method localNormalAt*(s: Plane, p: Point3): Vector3 =
  vector(0, 1, 0)