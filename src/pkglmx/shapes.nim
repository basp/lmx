import math, sequtils, options
import geometry, transform, common

type
  Sphere* = ref object of Shape
  Plane* = ref object of Shape
  Cube* = ref object of Shape
  Cylinder* = ref object of Shape
    min*, max*: float
    closed*: bool
  Triangle* = ref object of Shape
    p1*, p2*, p3*: Point3
    e1*, e2*, normal*: Vector3
  Group* = ref object of Shape
    objects*: seq[Shape]
  Operation* = enum
    opUnion
    opIntersection
    opDifference    
  Csg* = ref object of Shape
    op*: Operation
    left*, right*: Shape

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

proc newTriangle*(p1, p2, p3: Point3): Triangle {.inline.} =
  result = new Triangle
  result.transform = initTransform(identityMatrix)
  result.material = initMaterial()
  result.p1 = p1
  result.p2 = p2
  result.p3 = p3
  result.e1 = p2 - p1
  result.e2 = p3 - p1
  result.normal = cross(result.e2, result.e1).normalize()

proc newGroup*(): Group {.inline.} =
  result = new Group

template add*(g: Group, s: Shape) =
  s.parent = some(Shape(g))
  g.objects.add(s)

template len*(g: Group): int =
  len(g.objects)

method includes*(s: Group, other: Shape): bool =
  s.objects.contains(other)

proc newCsg*(op: Operation, left, right: Shape): Csg {.inline.} =
  result = new Csg
  result.op = op
  result.left = left
  result.right = right
  left.parent = some(Shape(result))
  right.parent = some(Shape(result))

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

method localIntersect*(s: Cylinder, r: Ray): seq[Intersection] =
  proc checkCap(t: float): bool =
    let 
      x = r.origin.x + t * r.direction.x
      z = r.origin.z + t * r.direction.z
    (x * x + z * z) <= 1

  proc intersectCaps(): seq[Intersection] =
    if (not s.closed) or (abs(r.direction.y) < epsilon):
      return
    var t: float
    t = (s.min - r.origin.y) / r.direction.y
    if checkCap(t):
      result.add(intersection(t, s))
    t = (s.max - r.origin.y) / r.direction.y
    if checkCap(t):
      result.add(intersection(t, s))

  let a = pow(r.direction.x, 2) + pow(r.direction.z, 2)
  if abs(a) < epsilon:
    return intersectCaps()
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
  result.concat(intersectCaps())

method localNormalAt*(s: Cylinder, p: Point3): Vector3 =
  let dist = (p.x * p.x + p.z * p.z)
  if dist < 1 and p.y >= s.max - epsilon:
    return vector(0, 1, 0)
  if dist < 1 and p.y <= s.min + epsilon:
    return vector(0, -1, 0)
  vector(p.x, 0, p.z)

method localIntersect*(s: Triangle, r: Ray): seq[Intersection] =
  let
    dirCrossE2 = cross(r.direction, s.e2)
    det = dot(s.e1, dirCrossE2)
  if abs(det) < epsilon:
    return @[]
  let
    f = 1.0 / det
    p1ToOrigin = r.origin - s.p1
    u = f * dot(p1ToOrigin, dirCrossE2)
  if u < 0 or u > 1:
    return @[]
  let
    originCrossE1 = cross(p1ToOrigin, s.e1)
    v = f * dot(r.direction, originCrossE1)
  if v < 0 or (u + v) > 1:
    return @[]
  let t = f * dot(s.e2, originCrossE1)
  @[intersection(t, s)]

method localNormalAt*(s: Triangle, p: Point3): Vector3 =
  s.normal

method localIntersect*(s: Group, r: Ray): seq[Intersection] =
  for obj in s.objects:
    for i in obj.intersect(r):
      result.add(i)
  result.intersections()

method localNormalAt*(s: Group, p: Point3): Vector3 =
  raise newException(Exception, "not implemented")

method includes*(s: Csg, other: Shape): bool =
  s.left == other or s.right == other

proc intersectionAllowed*(op: Operation, lhit, inl, inr: bool): bool =
  if op == opUnion:
    return (lhit and not inr) or (not lhit and not inl)
  if op == opIntersection:
    return (lhit and inr) or (not lhit and inl)
  if op == opDifference:
    return (lhit and not inr) or (not lhit and inl)

proc filterIntersections*(csg: Csg, xs: seq[Intersection]): seq[Intersection] =
  var
    inl = false
    inr = false
  for i in xs:
    let lhit = csg.left.includes(i.obj)
    if csg.op.intersectionAllowed(lhit, inl, inr):
      result.add(i)
    if lhit:
      inl = not inl
    else:
      inr = not inr

method localIntersect*(s: Csg, r: Ray): seq[Intersection] =
  let
    leftXs = s.left.intersect(r)
    rightXs = s.right.intersect(r)
    xs = concat(leftXs, rightXs)
  s.filterIntersections(xs.intersections())
