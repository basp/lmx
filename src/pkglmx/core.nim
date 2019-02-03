import math, sequtils, options, algorithm, times, linalg
{.experimental: "parallel".}

type 
  Ray* = tuple[origin: Vec4, direction: Vec4]
  PointLight = tuple[intensity: Color, position: Vec4]
  Pattern* = ref object of RootObj
    a*: Color
    b*: Color
    transform*: Matrix[4]
  Material = object
    color*: Color
    ambient*: float
    diffuse*: float
    specular*: float
    shininess*: float
    reflective*: float
    pattern*: Option[Pattern]
    transparency*: float
    refractive_index*: float
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
    under_point*: Vec4
    eyev*: Vec4
    normalv*: Vec4
    reflectv*: Vec4
    inside*: bool
    n1*: float
    n2*: float
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
  result.color = color(1, 1, 1)
  result.ambient = 0.1
  result.diffuse = 0.9
  result.specular = 0.9
  result.shininess = 200.0
  result.reflective = 0.0
  result.pattern = none(Pattern)
  result.refractive_index = 1.0

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

proc prepare_computations*(x: Intersection, ray: Ray, xs: seq[Intersection]): PrepComps =
  result.t = x.t
  result.obj = x.obj
  result.point = position(ray, result.t)
  result.eyev = -ray.direction
  result.normalv = normal_at(result.obj, result.point)
  result.inside = false
  let normalv_dot_eyev = dot(result.normalv, result.eyev)
  if normalv_dot_eyev < 0:
    result.inside = true
    result.normalv = -result.normalv  
  result.reflectv = reflect(ray.direction, result.normalv)
  result.over_point = result.point + result.normalv * epsilon
  result.under_point = result.point - result.normalv * epsilon
  
  var containers: seq[Shape]
  for i in xs:
    if i == x:
      if len(containers) == 0:
        result.n1 = 1.0
      else:
        result.n1 = containers[containers.high].material.refractive_index    
    
    if containers.contains(i.obj):
      containers.delete(containers.find(i.obj))
    else:
      containers.add(i.obj)    
    
    if i == x:
      if len(containers) == 0:
        result.n2 = 1.0
      else:
        result.n2 = containers[containers.high].material.refractive_index
      return

proc is_shadowed*(w: World, p: Vec4, light: PointLight): bool {.inline.} =
  let
    v = light.position - p
    distance = magnitude(v)
    direction = normalize(v)
    r = ray(p, direction)
    xs = intersect_world(w, r)
    h = hit(xs)
  h.is_some() and h.get().t < distance

proc color_at*(world: World, ray: Ray, remaining = 5): Color

proc reflected_color*(w: World, comps: PrepComps, remaining = 5): Color {.inline.} =
  if comps.obj.material.reflective == 0:
    return BLACK
  let 
    reflect_ray = ray(comps.over_point, comps.reflectv)
    color = color_at(w, reflect_ray, pred(remaining))  
  return color * comps.obj.material.reflective  

proc refracted_color*(w: World, comps: PrepComps, remaining = 5): Color {.inline.} =
  # max recursion
  if remaining < 1: return BLACK 
  
  # opaque object
  if comps.obj.material.transparency == 0: return BLACK
  
  let
    n_ratio = comps.n1 / comps.n2
    cos_i = dot(comps.eyev, comps.normalv)
    sin2_t = n_ratio * n_ratio * (1 - cos_i * cos_i)
  
  # total internal refraction
  if sin2_t > 1: return BLACK 
  
  let
    cos_t = sqrt(1.0 - sin2_t)
    direction = comps.normalv * (n_ratio * cos_i - cos_t) - comps.eyev * n_ratio
    refract_ray = ray(comps.under_point, direction)  

  color_at(w, refract_ray, pred(remaining)) * comps.obj.material.transparency

proc schlick*(comps: PrepComps): float {.inline.} =
  var cos = dot(comps.eyev, comps.normalv)
  if comps.n1 > comps.n2:
    let 
      n = comps.n1 / comps.n2
      sin2_t = n * n * (1.0 - cos * cos)
    if sin2_t > 1.0:
      return 1.0
    let cos_t = sqrt(1.0 - sin2_t)
    cos = cos_t      
  let r0 = pow((comps.n1 - comps.n2) / (comps.n1 + comps.n2), 2)
  r0 + (1 - r0) * pow(1 - cos, 5)

proc shade_hit*(world: World, comps: PrepComps, remaining = 5): Color {.inline.} =
  result = BLACK
  for light in world.lights:
    let 
      shadowed = is_shadowed(world, comps.over_point, light)
      surface = lighting(comps.obj.material, comps.obj, light, 
                        comps.over_point, comps.eyev, comps.normalv, 
                        shadowed)
      reflected = reflected_color(world, comps, remaining)
      refracted = refracted_color(world, comps, remaining)
      material = comps.obj.material
    if material.reflective > 0 and material.transparency > 0:
      let reflectance = schlick(comps)
      result = result + (surface + reflected * reflectance + refracted * (1 - reflectance))
    else:
      result = result + (surface + reflected + refracted)

proc color_at*(world: World, ray: Ray, remaining = 5): Color =
  if remaining < 1: return BLACK
  let 
    xs = intersect_world(world, ray)
    maybe_hit = hit(xs)
  if maybe_hit.is_none(): 
    return BLACK
  let 
    hit = maybe_hit.get()
    comps = prepare_computations(hit, ray, xs)
  shade_hit(world, comps, remaining)

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