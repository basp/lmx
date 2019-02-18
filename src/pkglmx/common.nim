import math, options, algorithm
import geometry, colors, transform

const epsilon* = 0.00001

type
  Pattern* = ref object of RootObj
    transform*: Transform
  Material* = object
    pattern*: Option[Pattern]
    color*: Color
    ambient*, diffuse*, specular*, shininess*, 
      reflective*, transparency*, refractiveIndex*: float
  Shape* = ref object of RootObj
    material*: Material
    transform*: Transform
  Intersection* = object
    t*: float
    obj*: Shape
  Computations* = object
    t*, n1*, n2*: float
    obj*: Shape
    point*, overPoint*, underPoint*: Point3
    eyev*, normalv*, reflectv*: Vector3
    inside*: bool
  PointLight* = ref object of RootObj
    position*: Point3
    intensity*: Color

proc newPointLight*(position: Point3, intensity: Color): PointLight {.inline.} =
  result = new PointLight
  result.position = position
  result.intensity = intensity

method colorAt*(pat: Pattern, p: Point3): Color {.base.} =
  raise newException(Exception, "not implemented")

proc colorAt*(pat: Pattern, obj: Shape, worldPoint: Point3): Color =
  let
    objPoint = obj.transform.inv * worldPoint
    patPoint = pat.transform.inv * objPoint
  pat.colorAt(patPoint)

proc initMaterial*(): Material {.inline.} =
  result.pattern = none(Pattern)
  result.color = color(1, 1, 1)
  result.ambient = 0.1
  result.diffuse = 0.9
  result.specular = 0.9
  result.shininess = 200
  result.transparency = 0
  result.refractiveIndex = 1

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

proc precompute*(hit: Intersection, r: Ray, xs: seq[Intersection]): Computations {.inline.} =
  result.t = hit.t
  result.obj = hit.obj
  result.point = r.position(result.t)
  result.eyev = -r.direction
  result.normalv = result.obj.normalAt(result.point)
  if dot(result.normalv, result.eyev) < 0:
    result.inside = true
    result.normalv = -result.normalv
  else:
    result.inside = false
  result.overPoint = result.point + result.normalv * epsilon
  result.underPoint = result.point - result.normalv * epsilon
  result.reflectv = r.direction.reflect(result.normalv)
  var containers: seq[Shape]
  for i in xs:
    if i == hit:
      if len(containers) == 0:
        result.n1 = 1.0
      else:
        result.n1 = containers[containers.high].material.refractiveIndex
    
    if containers.contains(i.obj):
      let idx = containers.find(i.obj)
      containers.delete(idx)
    else:
      containers.add(i.obj)

    if i == hit:
      if len(containers) == 0:
        result.n2 = 1.0
      else:
        result.n2 = containers[containers.high].material.refractiveIndex
      break

proc precompute*(i: Intersection, r: Ray): Computations {.inline.} =
  precompute(i, r, @[i])

proc schlick*(comps: Computations): float {.inline.} =
  var cos = dot(comps.eyev, comps.normalv)
  if comps.n1 > comps.n2:
    let 
      n = comps.n1 / comps.n2
      sin2t = n * n * (1.0 - cos * cos)
    if sin2t > 1.0: return 1.0
    let cost = sqrt(1.0 - sin2t)
    cos = cost
  let r0 = pow((comps.n1 - comps.n2) / (comps.n1 + comps.n2), 2)
  return r0 + (1 - r0) * pow(1 - cos, 5)
