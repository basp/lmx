import math, sequtils, options, algorithm, times, linalg
{.experimental: "parallel".}

type 
  Ray* = tuple[origin: Vec4, direction: Vec4]
  PointLight = tuple[intensity: Color, position: Vec4]
  Pattern* = ref object of RootObj
    a*: Color
    b*: Color
    transform*: Matrix[4]
  Material = tuple[color: Color, ambient: float, diffuse: float, 
                   specular: float, shininess: float, 
                   reflective: float, pattern: Option[Pattern]]
  Shape* = ref object of RootObj
    transform*: Matrix[4]
    material*: Material
    saved_ray*: Ray
  Intersection* = tuple[t: float, obj: Shape]
  World* = tuple[objects: seq[Shape], lights: seq[PointLight]]
  PrepComps = object
    t*: float
    obj*: Shape
    point*: Vec4
    over_point*: Vec4
    eyev*: Vec4
    normalv*: Vec4
    reflectv*: Vec4
    inside*: bool
  Camera* = ref object
    hsize*: int
    vsize*: int
    fov*: float
    transform*: Matrix[4]
    pixel_size*: float
    half_width: float
    half_height: float

proc ray*(origin: Vec4, direction: Vec4): Ray {.inline.} =
  (origin, direction)

proc position*(ray: Ray, t: float): Vec4 {.inline.} =
  ray.origin + ray.direction * t

proc intersection*(t: float, obj: Shape): Intersection {.inline.} =
  (t, obj)

proc intersections*(xs: varargs[Intersection]): seq[Intersection] {.inline.} =
  result = @(xs)
  result.sort do (x, y: Intersection) -> int: system.cmp(x.t, y.t)

proc hit*(xs: seq[Intersection]): Option[Intersection] {.inline.} =
  var valid = filter(xs) do (i: Intersection) -> bool : i.t >= 0
  if len(valid) == 0: return none(Intersection)
  valid.sort do (x, y: Intersection) -> int: system.cmp(x.t, y.t)
  return some(valid[0])

proc transform*(ray: Ray, t: Matrix[4]): Ray {.inline.} =
  (t * ray.origin, t * ray.direction)

method local_intersect*(obj: Shape, tr: Ray): seq[Intersection] {.base.} =
  @[]

proc intersect*(obj: Shape, ray: Ray): seq[Intersection] {.inline.} =
  let tr = transform(ray, inverse(obj.transform))
  obj.saved_ray = tr
  return local_intersect(obj, tr)

method local_normal_at*(obj: Shape, local_point: Vec4): Vec4 {.base.} =
  quit "TILT"

proc normal_at*(obj: Shape, world_point: Vec4): Vec4 {.inline.} =
  let
    local_point = inverse(obj.transform) * world_point
    local_normal = local_normal_at(obj, local_point)
  var world_normal = inverse(obj.transform).transpose() * local_normal
  world_normal.w = 0.0
  normalize(world_normal)

proc reflect*(a: Vec4, normal: Vec4): Vec4 {.inline.} =
  a - normal * 2 * dot(a, normal)

proc point_light*(position: Vec4, intensity: Color): PointLight {.inline.} =
  (intensity, position)

proc material*(): Material {.inline.} =
  (color(1, 1, 1), 0.1, 0.9, 0.9, 200.0, 0.0, none(Pattern))

proc init_pattern*(pat: Pattern) {.inline.} =
  pat.transform = identity

proc init_shape*(shape: Shape) {.inline.} =
  shape.material = material()
  shape.transform = identity

method pattern_at*(pat: Pattern,  p: Vec4): Color {.base.} =
  return

proc pattern_at_shape*(pat: Pattern, obj: Shape, world_point: Vec4): Color {.inline.} =
  let
    obj_point = inverse(obj.transform) * world_point
    pat_point = inverse(pat.transform) * obj_point
  pattern_at(pat, pat_point)

proc lighting*(material: Material, obj: Shape, light: PointLight, point: Vec4, 
               eyev: Vec4, normalv: Vec4, in_shadow = false): Color {.inline.} =
  let color = if material.pattern.is_some():
    pattern_at_shape(material.pattern.get(), obj, point)
  else:
    material.color
  let
    effective_color = color * light.intensity
    lightv = normalize(light.position - point)
    ambient = effective_color * material.ambient
    light_dot_normal = dot(lightv, normalv)
  var
    diffuse, specular: Color
  if in_shadow: return ambient
  if light_dot_normal >= 0:
    diffuse = effective_color * material.diffuse * light_dot_normal
    let 
      reflectv = reflect(-lightv, normalv)
      reflect_dot_eye = dot(reflectv, eyev)
    if reflect_dot_eye > 0:
      let factor = pow(reflect_dot_eye, material.shininess)
      specular = light.intensity * material.specular * factor
  ambient + diffuse + specular

proc world*(): World {.inline.} = 
  (@[], @[])

iterator world_intersections(world: World, ray: Ray): Intersection =
  for obj in world.objects:
    for x in intersect(obj, ray):
      yield x

proc intersect_world*(world: World, ray: Ray): seq[Intersection] =
  toSeq(world_intersections(world, ray)).intersections()

proc prepare_computations*(x: Intersection, ray: Ray): PrepComps {.inline.} =
  var
    t = x.t
    obj = x.obj
    point = position(ray, t)
    eyev = -ray.direction
    normalv = normal_at(obj, point)
    normalv_dot_eyev = dot(normalv, eyev)
    inside = false
    over_point = point + normalv * epsilon
  if normalv_dot_eyev < 0:
    inside = true
    normalv = -normalv
  let reflectv = reflect(ray.direction, normalv)
  PrepComps(t: t, obj: obj, point: point, over_point: over_point, 
            eyev: eyev, normalv: normalv, reflectv: reflectv,
            inside: inside)

proc is_shadowed*(w: World, p: Vec4, light: PointLight): bool {.inline.} =
  let
    v = light.position - p
    distance = magnitude(v)
    direction = normalize(v)
    r = ray(p, direction)
    xs = intersect_world(w, r)
    h = hit(xs)
  h.is_some() and h.get().t < distance

proc color_at*(world: World, ray: Ray): Color {.inline.}

proc reflected_color*(w: World, comps: PrepComps): Color {.inline.} =
  if comps.obj.material.reflective == 0:
    return BLACK
  let 
    reflect_ray = ray(comps.over_point, comps.reflectv)
    color = color_at(w, reflect_ray)  
  return color * comps.obj.material.reflective  

proc shade_hit*(world: World, comps: PrepComps): Color {.inline.} =
  result = BLACK
  for light in world.lights:
    let shadowed = is_shadowed(world, comps.over_point, light)
    result = result + lighting(comps.obj.material, comps.obj, light, 
                         comps.over_point, comps.eyev, comps.normalv, 
                         shadowed)
    result = result + reflected_color(world, comps)    

proc color_at*(world: World, ray: Ray): Color {.inline.} =
  let 
    xs = intersect_world(world, ray)
    maybe_hit = hit(xs)
  if maybe_hit.is_none(): 
    return BLACK
  let 
    hit = maybe_hit.get()
    comps = prepare_computations(hit, ray)
  shade_hit(world, comps)

proc view_transform*(`from`: Vec4, to: Vec4, up: Vec4): Matrix[4] {.inline.} =
  let 
    forward = normalize(to - `from`)
    upn = normalize(up)
    left = cross(forward, upn)
    true_up = cross(left, forward)
  result = [[left.x, left.y, left.z, 0.0],
            [true_up.x, true_up.y, true_up.z, 0.0],
            [-forward.x, -forward.y, -forward.z, 0.0],
            [0.0, 0.0, 0.0, 1.0]]
  result = result * translation(-`from`.x, -`from`.y, -`from`.z)

proc camera*(hsize: int, vsize: int, fov: float): Camera {.inline.} =
  let 
    half_view = tan(fov / 2)
    aspect = hsize / vsize
    half_width = if aspect >= 1: half_view else: half_view * aspect
    half_height = if aspect >= 1: half_view / aspect else: half_view
    pixel_size = (half_width * 2) / float(hsize)
  Camera(hsize: hsize, vsize: vsize, fov: fov, 
         transform: identity, pixel_size: pixel_size,
         half_width: half_width, half_height: half_height)

proc ray_for_pixel*(camera: Camera, px: int, py: int): Ray {.inline.} =
  let 
    xoffset = (float(px) + 0.5) * camera.pixel_size
    yoffset = (float(py) + 0.5) * camera.pixel_size
    world_x = camera.half_width - xoffset
    world_y = camera.half_height - yoffset
    pixel = inverse(camera.transform) * point(world_x, world_y, -1)
    origin = inverse(camera.transform) * point(0, 0, 0)
    direction = normalize(pixel - origin)
  ray(origin, direction)