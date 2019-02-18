import math, sequtils
import geometry, transform, common

type
  Sphere* = ref object of Shape
  Plane* = ref object of Shape
  Cube* = ref object of Shape
  Cylinder* = ref object of Shape
    min*, max*: float
    closed*: bool

proc newSphere*(): Sphere {.inline.} =
  result = new Sphere
  result.transform = initTransform(identityMatrix)
  result.material = initMaterial()

proc newPlane*(): Plane {.inline.} =
  result = new Plane
  result.transform = initTransform(identityMatrix)
  result.material = initMaterial()

proc newCube*(): Cube {.inline.} =
  result = new Cube
  result.transform = initTransform(identityMatrix)
  result.material = initMaterial()

proc newCylinder*(): Cylinder {.inline.} =
  result = new Cylinder
  result.transform = initTransform(identityMatrix)
  result.material = initMaterial()
  result.min = -Inf
  result.max = Inf

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

method localIntersect*(s: Cube, r: Ray): seq[Intersection] =
    proc checkAxis(origin, direction: float): tuple[tmin, tmax: float] =
      let
        tminNum = -1 - origin
        tmaxNum = 1 - origin
      if abs(direction) >= epsilon:
        result.tmin = tminNum / direction
        result.tmax = tmaxNum / direction
      else:
        result.tmin = tminNum * Inf
        result.tmax = tmaxNum * Inf
      if result.tmin > result.tmax:
        let tmp = result.tmin
        result.tmin = result.tmax
        result.tmax = tmp

    let 
      (xtmin, xtmax) = checkAxis(r.origin.x, r.direction.x)
      (ytmin, ytmax) = checkAxis(r.origin.y, r.direction.y)
      (ztmin, ztmax) = checkAxis(r.origin.z, r.direction.z)
      tmin = max(@[xtmin, ytmin, ztmin])
      tmax = min(@[xtmax, ytmax, ztmax])
    if tmin > tmax:
      return @[]
    return intersections(
      intersection(tmin, s),
      intersection(tmax, s))

method localNormalAt*(s: Cube, p: Point3): Vector3 =
  let maxc = max(@[abs(p.x), abs(p.y), abs(p.z)])
  if maxc == abs(p.x):
    return vector(p.x, 0, 0)
  elif maxc == abs(p.y):
    return vector(0, p.y, 0)
  return vector(0, 0, p.z)

proc checkCap(r: Ray, t: float): bool =
  let 
    x = r.origin.x + t * r.direction.x
    z = r.origin.z + t * r.direction.z
  (x * x + z * z) <= 1

proc intersectCaps(s: Cylinder, r: Ray): seq[Intersection] =
  if (not s.closed) or (abs(r.direction.y) < epsilon):
    return
  var t: float
  t = (s.min - r.origin.y) / r.direction.y
  if checkCap(r, t):
    result.add(intersection(t, s))
  t = (s.max - r.origin.y) / r.direction.y
  if checkCap(r, t):
    result.add(intersection(t, s))

method localIntersect*(s: Cylinder, r: Ray): seq[Intersection] =
  let a = pow(r.direction.x, 2) + pow(r.direction.z, 2)
  if abs(a) < epsilon:
    return intersectCaps(s, r)
  let
    b = 2 * r.origin.x * r.direction.x +
        2 * r.origin.z * r.direction.z
    c = pow(r.origin.x, 2) + pow(r.origin.z, 2) - 1
    disc = b * b - 4 * a * c
  if disc < 0:
    return @[]
  var
    t0 = (-b - sqrt(disc)) / (2 * a)
    t1 = (-b + sqrt(disc)) / (2 * a)
  if t0 > t1:
    let tmp = t0
    t0 = t1
    t1 = tmp
  let y0 = r.origin.y + t0 * r.direction.y
  if s.min < y0 and y0 < s.max:
    result.add(initIntersection(t0, s))
  let y1 = r.origin.y + t1 * r.direction.y
  if s.min < y1 and y1 < s.max:
    result.add(initIntersection(t1, s))
  result.concat(intersectCaps(s, r))

method localNormalAt*(s: Cylinder, p: Point3): Vector3 =
  let dist = (p.x * p.x + p.z * p.z)
  if dist < 1 and p.y >= s.max - epsilon:
    return vector(0, 1, 0)
  if dist < 1 and p.y <= s.min + epsilon:
    return vector(0, -1, 0)
  vector(p.x, 0, p.z)