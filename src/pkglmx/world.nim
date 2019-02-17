import math, algorithm, options
import geometry, transform, colors

type
  Material = object
    color*: Color
    ambient*, diffuse*, specular*, shininess*: float
  Shape* = ref object of RootObj
    transform*: Transform
  Sphere* = ref object of Shape
    material*: Material
  Intersection = object
    t*: float
    obj*: Shape
  PointLight = ref object of RootObj
    position*: Point3
    intensity*: Color  

proc initMaterial*(): Material {.inline.} =
  result.color = color(1, 1, 1)
  result.ambient = 0.1
  result.diffuse = 0.9
  result.specular = 0.9
  result.shininess = 200

proc li*(m: Material, light: PointLight, 
         pos: Point3, eyev, normalv: Vector3): Color {.inline.} =
  let
    effectiveColor = m.color |*| light.intensity
    lightv = normalize(light.position - pos)
    ambient = effectiveColor * m.ambient
    # lightDotNormal represents the cosine of the angle between
    # the light vector and the normal vector. A negative number
    # means the light is on the other side of the surface.
    lightDotNormal = lightv.dot(normalv)
  var diffuse, specular: Color  
  if lightDotNormal < 0:
    diffuse = color(0, 0, 0)
    specular = color(0, 0, 0)
  else:
    diffuse = effectiveColor * m.diffuse * lightDotNormal
    let
      reflectv = reflect(-lightv, normalv)
      reflectDotEye = reflectv.dot(eyev)
    if reflectDotEye <= 0:
      specular = color(0, 0, 0)
    else:
      let factor = pow(reflectDotEye, m.shininess)
      specular = light.intensity * m.specular * factor
  ambient + diffuse + specular

proc newSphere*(): Sphere {.inline.} =
  result = new Sphere
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

method intersect*(s: Shape, r: Ray): seq[Intersection] {.base.} =
  raise newException(Exception, "not implemented")

method normalAt*(s: Shape, p: Point3): Vector3 {.base.} =
  raise newException(Exception, "not implemented")

method intersect*(s: Sphere, r: Ray): seq[Intersection] =
  let
    tr = s.transform.inv * r
    # convert origin to a vector so we can dot it
    sphereToRay = tr.origin - point(0, 0, 0)
    a = dot(tr.direction, tr.direction)
    b = 2 * dot(tr.direction, sphereToRay)
    c = dot(sphereToRay, sphereToRay) - 1
    discriminant = b * b - 4 * a * c
  if discriminant < 0: return @[]
  let
    t1 = (-b - sqrt(discriminant)) / (2 * a)
    t2 = (-b + sqrt(discriminant)) / (2 * a)
  intersections(
    intersection(t1, s),
    intersection(t2, s))

method normalAt*(s: Sphere, worldPoint: Point3): Vector3 =
  let 
    objPoint = s.transform.inv * worldPoint
    objNormal = objPoint - point(0, 0, 0)
    worldNormal = s.transform.invt * objNormal
  return worldNormal.normalize()