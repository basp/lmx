import math, lists

type
    Vec4* = tuple[x: float, y: float, z: float, w: float]
    Vec3* = tuple[x: float, y: float, z: float]
    Ray* = tuple[origin: Vec3, direction: Vec3]       
    Hit* = tuple[t: float, p: Vec3, normal: Vec3]
    Sphere* = tuple[center: Vec3, radius: float]

proc r*(v: Vec3): float {.inline.} =
    v.x
    
proc g*(v: Vec3): float {.inline.} =
    v.y
    
proc b*(v: Vec3): float {.inline.} =
    v.z
    
proc `+`*(v1: Vec3, v2: Vec3): Vec3 {.inline.} =
    (v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)

proc `-`*(v1: Vec3, v2: Vec3): Vec3 {.inline.} =
    (v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)

proc `*`*(c: float, v: Vec3): Vec3 {.inline.} =
    (c * v.x, c * v.y, c * v.z)

proc `/`*(v: Vec3, c: float): Vec3 {.inline.} =
    (v.x / c, v.y / c, v.z / c)

proc `-`*(v: Vec3): Vec3 {.inline.} =
    (-v.x, -v.y, -v.z)     

proc lengthSquared*(v: Vec3): float {.inline.} =
    v.x * v.x + v.y * v.y + v.z * v.z

proc length*(v: Vec3): float {.inline.} = 
    sqrt(v.lengthSquared())

proc normalize*(v: Vec3): Vec3 {.inline.} = 
    let len = v.length()
    (v.x / len, v.y / len, v.z / len)

proc p*(ray: Ray, t: float): Vec3 {.inline} =
    ray.origin + t * ray.direction

proc dot*(v1: Vec3, v2: Vec3): float {.inline} =
    (v1.x * v2.x + v1.y * v2.y + v1.z * v2.z)

proc hit*(s: Sphere, r: Ray, tmin: float, tmax: float, hit: var Hit): bool =
    let 
        oc = r.origin - s.center
        a = dot(r.direction, r.direction)
        b = 2.0 * dot(oc, r.direction)
        c = dot(oc, oc) - s.radius * s.radius
        discriminant = b * b - 4 * a * c
    if discriminant > 0:
        var tmp: float
        tmp = (-b - sqrt(discriminant)) / (2.0 * a)
        if tmp < tmax and tmp > tmin:
            hit.t = tmp;
            hit.p = r.p(hit.t)
            hit.normal = (hit.p - s.center) / s.radius
            return true
        tmp = (-b + sqrt(discriminant)) / (2.0 * a)
        if tmp < tmax and tmp > tmin:
            hit.t = tmp
            hit.p = r.p(hit.t)
            hit.normal = (hit.p - s.center) / s.radius
            return true
        return false

proc hit*(ss: seq[Sphere], r: Ray, tmin: float, tmax: float, hit: var Hit): bool =
    var 
        tmp: Hit
        hitAnything = false
        closestSoFar = tmax
    
    for s in ss:
        if s.hit(r, tmin, closestSoFar, tmp):
            hitAnything = true
            closestSoFar = tmp.t
            hit = tmp
    
    return hitAnything