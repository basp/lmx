import math, core, linalg

type
    Sphere* = ref object of Shape
    Plane* = ref object of Shape

proc sphere*(): Sphere {.inline.} = 
  result = Sphere()
  init_shape(result)

proc plane*(): Plane {.inline.} =
  result = Plane()
  init_shape(result)
  
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
  if abs(tr.direction.y) < epsilon: return @[]
  let t = -tr.origin.y / tr.direction.y
  @[intersection(t, Shape(obj))] 

method local_normal_at*(obj: Sphere, local_point: Vec4): Vec4 =
  local_point - point(0, 0, 0)

method local_normal_at*(obj: Plane, local_point: Vec4): Vec4 =
  vector(0, 1, 0)
