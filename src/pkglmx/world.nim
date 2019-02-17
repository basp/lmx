import math, algorithm, options, sequtils
import geometry, transform, colors

const epsilon* = 0.00001

type
  Pattern* = ref object of RootObj
    transform*: Transform
  StripePattern = ref object of Pattern
    a*, b*: Color
  GradientPattern = ref object of Pattern
    a*, b*: Color
  RingPattern = ref object of Pattern
    a*, b*: Color
  CheckersPattern = ref object of Pattern
    a*, b*: Color
  Material = object
    pattern*: Option[Pattern]
    color*: Color
    ambient*, diffuse*, specular*, shininess*, 
      reflective*: float
  Shape* = ref object of RootObj
    material*: Material
    transform*: Transform
  Sphere* = ref object of Shape
  Plane* = ref object of Shape
  Intersection* = object
    t*: float
    obj*: Shape
  PointLight = ref object of RootObj
    position*: Point3
    intensity*: Color
  Computations* = object
    t*: float
    obj*: Shape
    point*: Point3
    overPoint*: Point3
    eyev*, normalv*: Vector3
    inside*: bool
  World* = ref object of RootObj
    objects*: seq[Shape]
    lights*: seq[PointLight]  

method colorAt*(pat: Pattern, p: Point3): Color {.base.} =
  raise newException(Exception, "not implemented")

proc newWorld*(): World {.inline.} =
  result = new World

proc initMaterial*(): Material {.inline.} =
  result.pattern = none(Pattern)
  result.color = color(1, 1, 1)
  result.ambient = 0.1
  result.diffuse = 0.9
  result.specular = 0.9
  result.shininess = 200

proc newStripePattern*(a, b: Color): StripePattern {.inline.} =
  result = new StripePattern
  result.transform = identityMatrix.initTransform()
  result.a = a
  result.b = b

proc newGradientPattern*(a, b: Color): GradientPattern {.inline.} =
  result = new GradientPattern
  result.transform = identityMatrix.initTransform()
  result.a = a
  result.b = b

proc newRingPattern*(a, b: Color): RingPattern {.inline.} =
  result = new RingPattern
  result.transform = identityMatrix.initTransform()
  result.a = a
  result.b = b

proc newCheckersPattern*(a, b: Color): CheckersPattern {.inline.} =
  result = new CheckersPattern
  result.transform = identityMatrix.initTransform()
  result.a = a
  result.b = b

method colorAt*(pat: StripePattern, p: Point3): Color =
  if floor(p.x) mod 2 == 0: pat.a else: pat.b

method colorAt*(pat: GradientPattern, p: Point3): Color =
  let
    distance = pat.b - pat.a
    fraction = p.x - floor(p.x)
  pat.a + distance * fraction

method colorAt*(pat: RingPattern, p: Point3): Color =
  if floor(sqrt(p.x * p.x + p.z + p.z)) mod 2 == 0: pat.a else: pat.b

method colorAt*(pat: CheckersPattern, p: Point3): Color =
  let
    fx = floor(p.x)
    fy = floor(p.y)
    fz = floor(p.z)
  if (fx + fy + fz) mod 2 == 0: pat.a else: pat.b

proc colorAt*(pat: Pattern, obj: Shape, worldPoint: Point3): Color =
  let
    objPoint = obj.transform.inv * worldPoint
    patPoint = pat.transform.inv * objPoint
  pat.colorAt(patPoint)

proc li*(m: Material, obj: Shape, light: PointLight, 
         pos: Point3, eyev, normalv: Vector3,
         shadow = false): Color {.inline.} =
  var color: Color
  if m.pattern.isSome():
    color = m.pattern.get().colorAt(obj, pos)
  else:
    color = m.color
  let
    effectiveColor = color |*| light.intensity
    lightv = normalize(light.position - pos)
    ambient = effectiveColor * m.ambient
    lightDotNormal = lightv.dot(normalv)
  var diffuse, specular: Color  
  if shadow:
    return ambient
  elif lightDotNormal < 0:
    # lightDotNormal represents the cosine of the angle between
    # the light vector and the normal vector. A negative number
    # means the light is on the other side of the surface.
    diffuse = color(0, 0, 0)
    specular = color(0, 0, 0)
  else:
    diffuse = effectiveColor * m.diffuse * lightDotNormal
    let
      reflectv = reflect(-lightv, normalv)
      reflectDotEye = reflectv.dot(eyev)
    if reflectDotEye <= 0:
      # reflectDotEye represents the cosine of the angle between
      # reflection vector and eye vector. A negative number means
      # the light reflects away from the eye
      specular = color(0, 0, 0)
    else:
      let factor = pow(reflectDotEye, m.shininess)
      specular = light.intensity * m.specular * factor
  ambient + diffuse + specular

proc newSphere*(): Sphere {.inline.} =
  result = new Sphere
  result.transform = initTransform(identityMatrix)
  result.material = initMaterial()

proc newPlane*(): Plane {.inline.} =
  result = new Plane
  result.transform = initTransform(identityMatrix)
  result.material = initMaterial()

proc newPointLight*(position: Point3, intensity: Color): PointLight {.inline.} =
  result = new PointLight
  result.position = position
  result.intensity = intensity

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

method localIntersect*(s: Shape, r: Ray): seq[Intersection] {.base.} =
  raise newException(Exception, "not implemented")

method localNormalAt*(s: Shape, p: Point3): Vector3 {.base.} =
  raise newException(Exception, "not implemented")

proc intersect*(s: Shape, r: Ray): seq[Intersection] =
  let tr = s.transform.inv * r
  localIntersect(s, tr) 

proc normalAt*(s: Shape, p: Point3): Vector3 =
  let
    localPoint = s.transform.inv * p
    localNormal = localNormalAt(s, localPoint)
    worldNormal = s.transform.invt * localNormal
  worldNormal.normalize()

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

proc precompute*(i: Intersection, r: Ray): Computations {.inline.} =
  result.t = i.t
  result.obj = i.obj
  result.point = r.position(result.t)
  result.eyev = -r.direction
  result.normalv = result.obj.normalAt(result.point)
  if dot(result.normalv, result.eyev) < 0:
    result.inside = true
    result.normalv = -result.normalv
  else:
    result.inside = false
  result.overPoint = result.point + result.normalv * epsilon

iterator intersections*(w: World, ray: Ray): Intersection =
  for obj in w.objects:
    for x in obj.intersect(ray):
      yield x

proc intersect*(w: World, ray: Ray): seq[Intersection] {.inline.} =
  toSeq(w.intersections(ray)).intersections()

proc shadowed*(w: World, p: Point3, light: PointLight): bool {.inline.} =
  let
    v = light.position - p
    distance = v.magnitude()
    direction = v.normalize()
    r = ray(p, direction)
    ix = w.intersect(r)
    maybeHit = ix.tryGetHit()
  maybeHit.isSome() and maybeHit.get().t < distance

proc shade*(w: World, comps: Computations): Color {.inline.} =
  let m = comps.obj.material
  for light in w.lights:
    let shadow = w.shadowed(comps.overPoint, light)
    result += m.li(comps.obj, light, comps.overPoint, 
                   comps.eyev, comps.normalv, shadow)

proc colorAt*(w: World, ray: Ray): Color {.inline.} =
  let 
    xs = w.intersect(ray)
    maybeHit = xs.tryGetHit()
  if maybeHit.isNone():
    return color(0, 0, 0)
  let 
    hit = maybeHit.get()
    comps = hit.precompute(ray)
  w.shade(comps)
