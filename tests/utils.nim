import pkglmx/common,
       pkglmx/geometry,
       pkglmx/render

proc `=~`*(v1, v2: Float): bool =
  const eps = 0.00001
  abs(v1 - v2) < eps
  
proc `=~`*[T](v1, v2: Vector3[T]): bool =
  v1.x =~ v2.x and v1.y =~ v2.y and v1.z =~ v2.z

proc `=~`*[T](p1, p2: Point3[T]): bool =
  p1.x =~ p2.x and p1.y =~ p2.y and p1.z =~ p2.z

proc `=~`*(c1, c2: Color): bool =
  c1.r =~ c2.r and c1.g =~ c2.g and c1.b =~ c2.b