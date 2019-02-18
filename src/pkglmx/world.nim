import math, options, sequtils
import geometry, transform, common, colors

type
  World* = ref object of RootObj
    objects*: seq[Shape]
    lights*: seq[PointLight]  

proc newWorld*(): World {.inline.} =
  result = new World

iterator intersections*(w: World, ray: Ray): Intersection =
  for obj in w.objects:
    for x in obj.intersect(ray):
      yield x

proc intersect*(w: World, ray: Ray): seq[Intersection] {.inline.} =
  toSeq(w.intersections(ray)).intersections()

proc colorAt*(w: World, ray: Ray, remaining = 5): Color {.inline.}

proc reflectedColor*(w: World, comps: Computations, 
                     remaining: int): Color {.inline.} =
  if remaining <= 0:
    return color(0, 0, 0)
  if abs(comps.obj.material.reflective) < epsilon:
    return color(0, 0, 0)
  let 
    reflectRay = initRay(comps.overPoint, comps.reflectv)
    color = w.colorAt(reflectRay, remaining - 1)
  color * comps.obj.material.reflective

proc refractedColor*(w: World, comps: Computations, 
                     remaining: int): Color {.inline.} =
  if remaining <= 0:
    return color(0, 0, 0)
  if abs(comps.obj.material.transparency) < epsilon:
    return color(0, 0, 0)
  let
    nRatio = comps.n1 / comps.n2
    cosi = comps.eyev.dot(comps.normalv)
    sin2t = nRatio * nRatio * (1 - cosi * cosi)
  if sin2t > 1:
    return color(0, 0, 0)
  let
    cost = sqrt(1.0 - sin2t)
    direction = comps.normalv * (nRatio * cosi - cost) - comps.eyev * nRatio
    refractRay = initRay(comps.underPoint, direction)
    color = w.colorAt(refractRay, remaining - 1)
  color * comps.obj.material.transparency

proc shadowed*(w: World, p: Point3, light: PointLight): bool {.inline.} =
  let
    v = light.position - p
    distance = v.magnitude()
    direction = v.normalize()
    r = ray(p, direction)
    ix = w.intersect(r)
    maybeHit = ix.tryGetHit()
  maybeHit.isSome() and maybeHit.get().t < distance

proc shade*(w: World, comps: Computations, remaining: int): Color {.inline.} =
  let m = comps.obj.material
  for light in w.lights:
    let 
      shadow = w.shadowed(comps.overPoint, light)      
      surface = m.li(comps.obj, 
                    light, 
                    comps.overPoint, 
                    comps.eyev, 
                    comps.normalv, 
                    shadow)
      reflected = w.reflectedColor(comps, remaining)
      refracted = w.refractedColor(comps, remaining)    
    if m.reflective > 0 and m.transparency > 0:
      let reflectance = comps.schlick()
      result += surface + reflected * reflectance + 
                          refracted * (1 - reflectance)
    else:
      result += surface + reflected + refracted

proc colorAt*(w: World, ray: Ray, remaining = 5): Color {.inline.} =
  let 
    xs = w.intersect(ray)
    maybeHit = xs.tryGetHit()
  if maybeHit.isNone():
    return color(0, 0, 0)
  let 
    hit = maybeHit.get()
    comps = hit.precompute(ray, xs)
  w.shade(comps, remaining)
