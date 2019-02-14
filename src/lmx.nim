import math
import pkglmx/geometry,
       pkglmx/sugar
export geometry,
       sugar

when isMainModule:
  let 
    v = vector(1, 2, 3.5)
    p = point(1, 2.5, 3)
    n = normal(1, 2, 3)
  echo v
  echo p
  echo n
  echo p[1]
  echo n[1]
  echo v + v