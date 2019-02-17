import math
import lmx

const
  sqrt2over2* = sqrt(2.0) / 2
  sqrt3over3* = sqrt(3.0) / 3

proc `=~`*(a, b: float): bool =
  const eps = 0.00001
  abs(a - b) < eps

template `=~`*(a, b: Vector3|Point3): bool =
  a.x =~ b.x and a.y =~ b.y and a.z =~ b.z

proc `=~`*(a, b: Color): bool =
  a.r =~ b.r and a.g =~ b.g and a.b =~ b.b

proc `=~`*(a, b: Matrix4x4): bool =
  for i in 0..3:
    for j in 0..3:
      if not (a[i, j] =~ b[i, j]): 
        return false
  true

proc `=~`*(a, b: Matrix3x3): bool =
  for i in 0..2:
    for j in 0..2:
      if not (a[i, j] =~ b[i, j]):
        return false
  true

proc `=~`*(a, b: Matrix2x2): bool =
  for i in 0..1:
    for j in 0..1:
      if not (a[i, j] =~ b[i, j]):
        return false
  true

proc newDefaultWorld*(): World =
  let 
    s1 = newSphere()
    s2 = newSphere()
    light = newPointLight(point(-10, 10, -10), color(1, 1, 1))
  s1.material.color = color(0.8, 1.0, 0.6)
  s1.material.diffuse = 0.7
  s1.material.specular = 0.2  
  s2.transform = initTransform(scaling(0.5, 0.5, 0.5))  
  result = newWorld()
  result.lights.add(light)
  result.objects.add(s1)
  result.objects.add(s2)

# proc `=~`*(a, b: Material): bool =
#   a.color =~ b.color and 
#     a.ambient =~ b.ambient and
#     a.diffuse =~ b.diffuse and
#     a.specular =~ b.specular