import os, math, sequtils, options, algorithm, times, random
{.experimental: "parallel".}

type
  Vec4* = tuple[x: float, y: float, z: float, w: float]
  Color* = tuple[r: float, g: float, b: float]
  Matrix*[N: static int] = array[0..pred(N), array[0..pred(N), float]]
  Ray* = tuple[origin: Vec4, direction: Vec4]
  PointLight = tuple[intensity: Color, position: Vec4]
  Pattern* = ref object of RootObj
    a*: Color
    b*: Color
    transform*: Matrix[4]
  Stripes = ref object of Pattern
  Rings = ref object of Pattern
  Checkers = ref object of Pattern
  Gradient = ref object of Pattern
  Material = tuple[color: Color, ambient: float, diffuse: float, 
                   specular: float, shininess: float, pattern: Option[Pattern]]
  Shape* = ref object of RootObj
    transform*: Matrix[4]
    material*: Material
    saved_ray*: Ray
  Sphere = ref object of Shape
  Plane = ref object of Shape
  Intersection = tuple[t: float, obj: Shape]
  World = tuple[objects: seq[Shape], lights: seq[PointLight]]
  PrepComps = object
    t*: float
    obj*: Shape
    point*: Vec4
    over_point*: Vec4
    eyev*: Vec4
    normalv*: Vec4
    inside*: bool
  Camera = ref object
    hsize*: int
    vsize*: int
    fov*: float
    transform*: Matrix[4]
    pixel_size*: float
    half_width: float
    half_height: float
  Canvas = ref object
    hsize: int
    vsize: int
    pixels: seq[Color]

const 
  BLACK*: Color = (0.0, 0.0, 0.0)
  WHITE*: Color = (1.0, 1.0, 1.0)

const identity*: Matrix[4] = [[1.0, 0.0, 0.0, 0.0],
                              [0.0, 1.0, 0.0, 0.0],
                              [0.0, 0.0, 1.0, 0.0],
                              [0.0, 0.0, 0.0, 1.0]]

const EPSILON* = 0.00001

proc is_point*(v: Vec4): bool {.inline.} =
  v.w == 1.0

proc is_vector*(v: Vec4): bool {.inline.} =
  v.w == 0.0

proc point*(x: float, y: float, z: float): Vec4 {.inline.} =
  (x, y, z, 1.0)

proc vector*(x: float, y: float, z: float): Vec4 {.inline.} =
  (x, y, z, 0.0)

proc color*(r: float, g: float, b: float): Color {.inline.} =
  (r, g, b)

proc `=~`*(a: float, b: float): bool {.inline.} =
  abs(a - b) < EPSILON

proc `=~`*(a: Vec4, b: Vec4): bool {.inline.} =
  a.x =~ b.x and a.y =~ b.y and a.z =~ b.z and a.w =~ b.w

proc `=~`*(a: Color, b: Color): bool {.inline.} =
  a.r =~ b.r and a.g =~ b.g and a.b =~ b.b

proc `+`*(a: Vec4, b: Vec4): Vec4 {.inline.} =
  (a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)

proc `+`*(a: Color, b: Color): Color {.inline.} =
  (a.r + b.r, a.g + b.g, a.b + b.b)

proc `-`*(a: Vec4, b: Vec4): Vec4 {.inline.} =
  (a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)

proc `-`*(a: Color, b: Color): Color {.inline.} =
  (a.r - b.r, a.g - b.g, a.b - b.b)

proc `-`*(a: Vec4): Vec4 {.inline.} =
  (-a.x, -a.y, -a.z, -a.w)

proc `*`*(c: float, a: Vec4): Vec4 {.inline.} =
  (c * a.x, c * a.y, c * a.z, c * a.w)

proc `*`*(c: float, a: Color): Color {.inline.} =
  (c * a.r, c * a.g, c * a.b)

proc `*`*(a: Vec4, c: float): Vec4 {.inline.} =
  (c * a.x, c * a.y, c * a.z, c * a.w)

proc `*`*(a: Color, c: float): Color {.inline.} =
  (c * a.r, c * a.g, c * a.b)

proc `*`*(a: Color, b: Color): Color {.inline.} =
  (a.r * b.r, a.g * b.g, a.b * b.b)

proc `/`*(a: Vec4, c: float): Vec4 {.inline.} =
  (a.x / c, a.y / c, a.z / c, a.w / c)

proc `/`*(a: Color, c: float): Color {.inline.} =
  (a.r / c, a.g / c, a.b / c)

proc magnitude*(a: Vec4): float {.inline.} =
  sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)

proc normalize*(a: Vec4): Vec4 {.inline.} =
  let mag = magnitude(a)
  (a.x / mag, a.y / mag, a.z / mag, a.w / mag)

proc dot*(a: Vec4, b: Vec4): float {.inline.} =
  a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w

proc cross*(a: Vec4, b: Vec4): Vec4 {.inline.} =
  vector(a.y * b.z - a.z * b.y,
         a.z * b.x - a.x * b.z,
         a.x * b.y - a.y * b.x)

proc `[]`*[N](m: Matrix[N], row: int, col: int): float {.inline.} =
  m[row][col]

proc row*[N](m: Matrix[N], row: int): Vec4 {.inline.} =
  (m[row][0], m[row][1], m[row][2], m[row][3])

proc col*[N](m: Matrix[N], col: int): Vec4 {.inline.} =
  (m[0][col], m[1][col], m[2][col], m[3][col])

proc `=~`*[N](a, b: Matrix[N]): bool {.inline.} =
  result = true
  for r in 0..N-1:
    for c in 0..N-1:
      if not (a[r][c] =~ b[r][c]):
        result = false

proc `*`*[N](a, b: Matrix[N]): Matrix[N] {.inline.} =
  for r in 0..N-1:
    for c in 0..N-1:
      result[r][c] = dot(row(a, r), col(b, c))

proc `*`*(a: Matrix[4], b: Vec4): Vec4 {.inline.} =
  (dot(row(a, 0), b), dot(row(a, 1), b), dot(row(a, 2), b), dot(row(a, 3), b))

proc transpose*[N](a: Matrix[N]): Matrix[N] {.inline.} =
  for r in 0..N-1:
    for c in 0..N-1:
      result[c][r] = a[r][c]

proc submatrix[N, M](a: Matrix[N], row: int, col: int): Matrix[M] {.inline.} =
  let 
    idxs = toSeq 0..N-1
    rows = filter(idxs) do (i: int) -> bool : i != row
    cols = filter(idxs) do (i: int) -> bool : i != col
  for r in 0..high(rows):
    for c in 0..high(cols):
      result[r][c] = a[rows[r]][cols[c]]

proc submatrix*(a: Matrix[4], row: int, col: int): Matrix[3] {.inline.} =
  submatrix[4, 3](a, row, col)
      
proc submatrix*(a: Matrix[3], row: int, col: int): Matrix[2] {.inline.} =
  submatrix[3, 2](a, row, col)

proc determinant*(a: Matrix[2]): float {.inline.} =
  a[0][0] * a[1][1] - a[0][1] * a[1][0]
  
proc minor*(a: Matrix[3], row: int, col: int): float {.inline.} =
  submatrix[3, 2](a, row, col).determinant()

proc cofactor*(a: Matrix[3], row: int, col: int): float {.inline.} =
  let m = minor(a, row, col)
  if (row + col) mod 2 == 0: m else: -m

proc determinant*(a: Matrix[3]): float {.inline.} =
  let 
    x = a[0][0] * cofactor(a, 0, 0)
    y = a[0][1] * cofactor(a, 0, 1)
    z = a[0][2] * cofactor(a, 0, 2)
  x + y + z

proc minor*(a: Matrix[4], row: int, col: int): float {.inline.} =
  submatrix[4, 3](a, row, col).determinant()

proc cofactor*(a: Matrix[4], row: int, col: int): float {.inline.} =
  let m = minor(a, row, col)
  if (row + col) mod 2 == 0: m else: -m

proc determinant*(a: Matrix[4]): float {.inline.} =
  let 
    x = a[0][0] * cofactor(a, 0, 0)
    y = a[0][1] * cofactor(a, 0, 1)
    z = a[0][2] * cofactor(a, 0, 2)
    w = a[0][3] * cofactor(a, 0, 3)
  x + y + z + w

proc is_invertible*(a: Matrix[4]): bool {.inline.} =
  not (determinant(a) =~ 0)

proc inverse*(a: Matrix[4]): Matrix[4] =
  let d = determinant(a)
  if d == 0: raise newException(Exception, "matrix is not invertible")
  for row in 0..3:
    for col in 0..3:
      let c = cofactor(a, row, col)
      # note that values are assigned transposed
      result[col][row] = c / d

proc translation*(x: float, y: float, z: float): Matrix[4] {.inline.} =
  [[1.0, 0.0, 0.0, x],
   [0.0, 1.0, 0.0, y],
   [0.0, 0.0, 1.0, z],
   [0.0, 0.0, 0.0, 1.0]]  

proc scaling*(x: float, y: float, z: float): Matrix[4] {.inline.} =
  [[x, 0.0, 0.0, 0.0],
   [0.0, y, 0.0, 0.0],
   [0.0, 0.0, z, 0.0],
   [0.0, 0.0, 0.0, 1.0]]

proc rotation_x*(r: float): Matrix[4] {.inline.} =
  [[1.0, 0.0, 0.0, 0.0],
   [0.0, cos(r), -sin(r), 0.0],
   [0.0, sin(r), cos(r), 0.0],
   [0.0, 0.0, 0.0, 1.0]]

proc rotation_y*(r: float): Matrix[4] {.inline.} =
  [[cos(r), 0.0, sin(r), 0.0],
   [0.0, 1.0, 0.0, 0.0],
   [-sin(r), 0.0, cos(r), 0.0],
   [0.0, 0.0, 0.0, 1.0]]

proc rotation_z*(r: float): Matrix[4] {.inline.} =
  [[cos(r), -sin(r), 0.0, 0.0],
   [sin(r), cos(r), 0.0, 0.0],
   [0.0, 0.0, 1.0, 0.0],
   [0.0, 0.0, 0.0, 1.0]]

proc shearing*(xy: float, xz: float, 
               yx: float, yz: float, 
               zx: float, zy: float): Matrix[4] {.inline.} =
  [[1.0, xy, xz, 0.0],
   [yx, 1.0, yz, 0.0],
   [zx, zy, 1.0, 0.0],
   [0.0, 0.0, 0.0, 1.0]]

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

method local_intersect*(obj: Sphere, tr: Ray): seq[Intersection] =
  let 
    sphere_to_ray = tr.origin - point(0, 0, 0)
    a = dot(tr.direction, tr.direction)
    b = 2 * dot(tr.direction, sphere_to_ray)
    c = dot(sphere_to_ray, sphere_to_ray) - 1.0
    discriminant = b * b - 4 * a * c  
  if discriminant < 0: return @[]
  let 
    t1 = (-b - sqrt(discriminant)) / (2 * a)
    t2 = (-b + sqrt(discriminant)) / (2 * a)
  @[(t1, Shape(obj)), (t2, Shape(obj))]

method local_intersect*(obj: Plane, tr: Ray): seq[Intersection] =
  if abs(tr.direction.y) < EPSILON: return @[]
  let t = -tr.origin.y / tr.direction.y
  @[intersection(t, Shape(obj))]

proc intersect*(obj: Shape, ray: Ray): seq[Intersection] {.inline.} =
  let tr = transform(ray, inverse(obj.transform))
  obj.saved_ray = tr
  return local_intersect(obj, tr)

method local_normal_at*(obj: Shape, local_point: Vec4): Vec4 {.base.} =
  quit "TILT"

method local_normal_at*(obj: Sphere, local_point: Vec4): Vec4 =
  local_point - point(0, 0, 0)

method local_normal_at*(obj: Plane, local_point: Vec4): Vec4 =
  vector(0, 1, 0)

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
  (color(1, 1, 1), 0.1, 0.9, 0.9, 200.0, none(Pattern))

proc init_pattern*(pat: Pattern) {.inline.} =
  pat.transform = identity

proc init_shape*(shape: Shape) {.inline.} =
  shape.material = material()
  shape.transform = identity

proc sphere*(): Sphere {.inline.} = 
  result = Sphere()
  init_shape(result)

proc plane*(): Plane {.inline.} =
  result = Plane()
  init_shape(result)

proc stripe_at*(pat: Stripes, p: Vec4): Color {.inline.} =
  if floor(p.x) mod 2 == 0: 
    return pat.a
  else:
    return pat.b

proc stripe_pattern*(a: Color, b: Color): Stripes {.inline.} =
  Stripes(a: a, b: b, transform: identity)

proc gradient_pattern*(a: Color, b: Color): Gradient {.inline.} =
  Gradient(a: a, b: b, transform: identity)

proc ring_pattern*(a: Color, b: Color): Rings {.inline.} =
  Rings(a: a, b: b, transform: identity)

proc checkers_pattern*(a: Color, b: Color): Checkers {.inline.} =
  Checkers(a: a, b: b)

method pattern_at*(pat: Pattern,  p: Vec4): Color {.base.} =
  return

method pattern_at*(pat: Stripes, p: Vec4): Color {.inline.} =
  stripe_at(pat, p)

method pattern_at*(pat: Rings, p: Vec4): Color {.inline.} =
  if floor(sqrt(p.x * p.x + p.z * p.z)) mod 2 == 0:
    return pat.a
  else:
    return pat.b

method pattern_at*(pat: Checkers, p: Vec4): Color {.inline.} =
    if (floor(p.x) + floor(p.y) + floor(p.z)) mod 2 == 0:
      return pat.a
    else:
      return pat.b

method pattern_at*(pat: Gradient, p: Vec4): Color =
  let
    distance = pat.b - pat.a
    fraction = p.x - floor(p.x)
  pat.a + distance * fraction

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

proc default_world*(): World {.inline.} =
  var  
    s1: Shape = sphere()
    s2: Shape = sphere()
  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  s1.material.color = color(0.8, 1.0, 0.6)
  s1.material.diffuse = 0.7
  s1.material.specular = 0.2
  s2.transform = scaling(0.5, 0.5, 0.5)
  (@[s1, s2], @[light])

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
    over_point = point + normalv * EPSILON
  if normalv_dot_eyev < 0:
    inside = true
    normalv = -normalv
  PrepComps(t: t, obj: obj, point: point, over_point: over_point, 
            eyev: eyev, normalv: normalv, inside: inside)

proc is_shadowed*(w: World, p: Vec4, light: PointLight): bool {.inline.} =
  let
    v = light.position - p
    distance = magnitude(v)
    direction = normalize(v)
    r = ray(p, direction)
    xs = intersect_world(w, r)
    h = hit(xs)
  h.is_some() and h.get().t < distance
            
proc shade_hit*(world: World, comps: PrepComps): Color {.inline.} =
  result = BLACK
  for light in world.lights:
    let shadowed = is_shadowed(world, comps.over_point, light)
    result = result + lighting(comps.obj.material, comps.obj, light, 
                               comps.over_point, comps.eyev, comps.normalv, 
                               shadowed)

proc color_at*(world: World, ray: Ray): Color {.inline.} =
  let 
    xs = intersect_world(world, ray)
    maybe_hit = hit(xs)
  if maybe_hit.is_none(): return BLACK
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

proc canvas*(hsize: int, vsize: int): Canvas {.inline.} =
  let pixels = newSeq[Color](hsize * vsize)
  Canvas(hsize: hsize, vsize: vsize, pixels: pixels)

proc write_pixel(canvas: Canvas, x: int, y: int, color: Color) {.inline.} =
  let i = y * canvas.hsize + x
  canvas.pixels[i] = color

proc render_antialias(camera: Camera, world: World): Canvas =
  result = canvas(camera.hsize, camera.vsize)
  for y in 0..pred(camera.vsize):
    let start = now()
    for x in 0..pred(camera.hsize):
      let
         r0 = ray_for_pixel(camera, x, y)
         r1 = ray_for_pixel(camera, pred(x), pred(y))
         r2 = ray_for_pixel(camera, pred(x), succ(y))
         r3 = ray_for_pixel(camera, succ(x), pred(y))
         r4 = ray_for_pixel(camera, succ(x), succ(y))
         c0 = color_at(world, r0)
         c1 = color_at(world, r1)
         c2 = color_at(world, r2)
         c3 = color_at(world, r3)
         c4 = color_at(world, r4)
         color = (c0 + c1 + c2 + c3 + c4) / 5.0
      # let 
      #   ray = ray_for_pixel(camera, x, y)
      #   color = color_at(world, ray)
      write_pixel(result, x, y, color)
    let 
      finish = now()
      dur = finish - start
    if isMainModule:
      echo succ(y), "/", camera.vsize, " (", dur, ")"  

proc render*(camera: Camera, world: World): Canvas =
  result = canvas(camera.hsize, camera.vsize)
  for y in 0..pred(camera.vsize):
    let start = now()
    for x in 0..pred(camera.hsize):
      let
        ray = ray_for_pixel(camera, x, y)
        color = color_at(world, ray)
      write_pixel(result, x, y, color)
    let 
      finish = now()
      dur = finish - start
    if isMainModule:
      echo succ(y), "/", camera.vsize, " (", dur, ")"

proc pixel_at*(canvas: Canvas, x: int, y: int): Color {.inline.} =
  canvas.pixels[y * canvas.hsize + x]

when is_main_module:
  proc clamp(value: int, min: int, max: int): int {.inline.} =
    if value < min: return min
    if value > max: return max
    value

  proc getRGB(c: Color): tuple[r: int, g: int, b: int] =
    # make sure we don't overflow colors (i.e. keep r, g, b <= 255)
    let
        r = int(255.99 * c.r).clamp(0, 255)
        g = int(255.99 * c.g).clamp(0, 255)
        b = int(255.99 * c.b).clamp(0, 255)
    (r, g, b)

  var w = world()

  var red_grey_stripes = stripe_pattern(color(1.0, 0.2, 0.2), color(0.5, 0.5, 0.5))
  
  var blue_grey_stripes = stripe_pattern(color(0.1, 0.3, 0.95), color(0.5, 0.5, 0.5))
  blue_grey_stripes.transform = scaling(0.5, 0, 0) * rotation_x(PI / 4)
  
  var pink_blue_stripes = stripe_pattern(color(0.9, 0.05, 0.6), color(0.2, 0.2, 1.0))
  pink_blue_stripes.transform = scaling(0.25, 0.25, 0.25)

  var g1 = gradient_pattern(color(0, 0.2, 0.3), color(1, 1, 1))
  # make sure to transform it so the gradient won't overflow
  g1.transform = translation(-1, 0, 0) * scaling(2, 2, 2)

  var checkers = checkers_pattern(color(0.8, 0.1, 0.8), color(0, 0, 0))
  checkers.transform = scaling(2, 2, 2)

  let floor: Shape = plane()
  floor.material = material()
  floor.material.color = color(1, 0.9, 0.9)
  floor.material.specular = 0
  floor.material.pattern = some(Pattern(checkers))

  let backdrop: Shape = plane()
  backdrop.material = material()
  backdrop.material.color = color(0.2, 0.3, 1.0)
  backdrop.material.specular = 0
  backdrop.material.pattern = some(Pattern(red_grey_stripes))
  backdrop.transform = translation(0, 0, 3.3) * 
                       rotation_x(-PI / 2)

  let middle: Shape = sphere()
  middle.transform = translation(-0.5, 0.5, 0.5) * rotation_z(PI / 5)
  middle.material = material()
  middle.material.color = color(0.1, 1, 0.5)
  middle.material.diffuse = 0.7
  middle.material.specular = 0.3
  middle.material.pattern = some(Pattern(pink_blue_stripes))

  let right: Shape = sphere()
  right.transform = translation(1.5, 0.5, -0.5) *
                    scaling(0.5, 0.5, 0.5)
  right.material = material()
  right.material.color = color(0.5, 1, 0.1)
  right.material.diffuse = 0.7
  right.material.specular = 0.3

  let left: Shape = sphere()
  left.transform = translation(-1.5, 0.33, -0.75) *
                   scaling(0.33, 0.33, 0.33)
  left.material = material()
  left.material.pattern = some(Pattern(g1))
  left.material.color = color(1, 0.8, 0.1)
  left.material.diffuse = 0.7
  left.material.specular = 0.3

  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  w.lights = @[light]
  w.objects = @[floor, backdrop, middle, right, left]

  let c = camera(1280, 1024, PI / 3)
  c.transform = view_transform(point(1.1, 1.4, -4),
                               point(0, 0.5, 0),
                               vector(0, 1, 0))
  
  let start = now()
  let img = render_antialias(c, w)
  let f = open("out.ppm", fmWrite)
  write_line(f, "P3")
  write_line(f, img.hsize, " ", img.vsize)
  write_line(f, 255)

  for y in 0..pred(img.vsize):
    for x in 0..pred(img.hsize):
      let rgb = pixel_at(img, x, y).getRGB()
      write_line(f, rgb.r, " ", rgb.g, " ", rgb.b)

  let finish = now()
  let duration = finish - start
  echo duration
