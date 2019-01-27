# Contains all of the lmx core libary.

import os, math, sequtils, options, algorithm, times

type
  Vec4* = tuple[x: float, y: float, z: float, w: float]
  Color* = tuple[r: float, g: float, b: float]
  Matrix*[N: static int] = array[0..pred(N), array[0..pred(N), float]]
  Ray* = tuple[origin: Vec4, direction: Vec4]
  PointLight = tuple[intensity: Color, position: Vec4]
  Material = tuple[color: Color, ambient: float, diffuse: float, 
                   specular: float, shininess: float]
  Sphere = ref object
    transform*: Matrix[4]
    material*: Material
  Intersection = tuple[t: float, obj: Sphere]
  World = tuple[objects: seq[Sphere], lights: seq[PointLight]]
  PrepComps = object
    t*: float
    obj*: Sphere
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
  if d =~ 0: raise newException(Exception, "matrix is not invertible")
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

proc intersection*(t: float, obj: Sphere): Intersection {.inline.} =
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

proc intersect*(obj: Sphere, ray: Ray): seq[Intersection] {.inline.} =
  var tr = transform(ray, inverse(obj.transform))
  let
    # the vector from the sphere's center to the ray's origin
    # note that sphere is assumed to be at origin
    sphere_to_ray = tr.origin - point(0, 0, 0)
    a = dot(tr.direction, tr.direction)
    b = 2 * dot(tr.direction, sphere_to_ray)
    c = dot(sphere_to_ray, sphere_to_ray) - 1.0
    discriminant = b * b - 4 * a * c
  if discriminant < 0: return @[]
  let
    t1 = (-b - sqrt(discriminant)) / (2 * a)
    t2 = (-b + sqrt(discriminant)) / (2 * a)
  @[(t1, obj), (t2, obj)]

proc normalAt*(obj: Sphere, world_point: Vec4): Vec4 {.inline.} =
  let
    obj_point = inverse(obj.transform) * world_point
    obj_normal = objPoint - point(0, 0, 0)
  var world_normal = inverse(obj.transform).transpose() * obj_normal
  world_normal.w = 0.0
  normalize(world_normal)

proc reflect*(a: Vec4, normal: Vec4): Vec4 {.inline.} =
  a - normal * 2 * dot(a, normal)

proc point_light*(position: Vec4, intensity: Color): PointLight {.inline.} =
  (intensity, position)

proc material*(): Material {.inline.} =
  (color(1, 1, 1), 0.1, 0.9, 0.9, 200.0)

proc sphere*(): Sphere {.inline.} = 
  Sphere(transform: identity, material: material())

proc lighting*(material: Material, light: PointLight, point: Vec4, 
               eyev: Vec4, normalv: Vec4, in_shadow = false): Color {.inline.} =
  let
    effective_color = material.color * light.intensity
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
    s1 = sphere()
    s2 = sphere()
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
    result = result + lighting(comps.obj.material, light, 
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
    echo "row ", succ(y), " of ", camera.vsize, " (", dur.milliseconds(), " ms)"

proc pixel_at*(canvas: Canvas, x: int, y: int): Color {.inline.} =
  canvas.pixels[y * canvas.hsize + x]

when is_main_module:
  proc clamp(value: int, min: int, max: int): int {.inline.} =
    if value < min: return min
    if value > max: return max
    value

  proc getRGB(c: Color): tuple[r: int, g: int, b: int] =
    # make sure we don't overflow colors (i.e. r, g, b > 255)
    let
        r = int(255.99 * c.r).clamp(0, 255)
        g = int(255.99 * c.g).clamp(0, 255)
        b = int(255.99 * c.b).clamp(0, 255)
    (r, g, b)

  var w = world()

  let floor = sphere()
  floor.transform = scaling(10, 0.01, 10)
  floor.material = material()
  floor.material.color = color(1, 0.9, 0.9)
  floor.material.specular = 0

  let left_wall = sphere()
  left_wall.transform = translation(0, 0, 5) *
                        rotation_y(-PI / 4) *
                        rotation_x(PI / 2) *
                        scaling(10, 0.01, 10)
  left_wall.material = floor.material

  let right_wall = sphere()
  right_wall.transform = translation(0, 0, 5) *
                         rotation_y(PI / 4) *
                         rotation_x(PI / 2) *
                         scaling(10, 0.01, 10)
  right_wall.material = floor.material

  let middle = sphere()
  middle.transform = translation(-0.5, 1, 0.5)
  middle.material = material()
  middle.material.color = color(0.1, 1, 0.5)
  middle.material.diffuse = 0.7
  middle.material.specular = 0.3

  let right = sphere()
  right.transform = translation(1.5, 0.5, -0.5) *
                    scaling(0.5, 0.5, 0.5)
  right.material = material()
  right.material.color = color(0.5, 1, 0.1)
  right.material.diffuse = 0.7
  right.material.specular = 0.3

  let left = sphere()
  left.transform = translation(-1.5, 0.33, -0.75) *
                   scaling(0.33, 0.33, 0.33)
  left.material = material()
  left.material.color = color(1, 0.8, 0.1)
  left.material.diffuse = 0.7
  left.material.specular = 0.3

  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  w.lights = @[light]
  w.objects = @[floor, left_wall, right_wall, middle, right, left]

  let c = camera(400, 200, PI / 3)
  c.transform = view_transform(point(0, 1.5, -5),
                               point(0, 1, 0),
                               vector(0, 1, 0))
  
  let start = now()
  let img = render(c, w)
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
