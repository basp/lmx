import lmx

proc `=~`*(a, b: float): bool =
  const eps = 0.00001
  abs(a - b) < eps

template `=~`*(a, b: Vector3|Point3|Normal3): bool =
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

# proc `=~`*(a, b: Material): bool =
#   a.color =~ b.color and 
#     a.ambient =~ b.ambient and
#     a.diffuse =~ b.diffuse and
#     a.specular =~ b.specular