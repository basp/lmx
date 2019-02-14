import geometry

template vector*(x, y, z: untyped): Vector3 =
  initVector3(x, y, z)

template point*(x, y, z: untyped): Point3 =
  initPoint3(x, y, z)

template normal*(x, y, z: untyped): Normal3 =
  initNormal3(x, y, z)

template `[]`*(t: Vector3|Point3|Normal3, i: int): float =
  case i 
  of 0: t.x
  of 1: t.y
  of 2: t.z
  else: raise newException(IndexError, "0 <= i < 3")

template `*`*(c: float, v: Vector3): Vector3 = 
  v * c